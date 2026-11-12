# Transferring database ownership to a new person

How to make a different person the real owner of the running Postgres
cluster, so they can `pgstart`/`pgstop` it themselves going forward —
not just connect to it while someone else keeps it running.

## This is not the same thing as backup-and-restore.md

[`backup-and-restore.md`](backup-and-restore.md)'s "Restore" section
creates a second database (`carenlp_db_restore`) inside the
same, already-running server — same `$PGDATA_HOST`, same owner. That's
the right tool for testing a restore safely alongside the live
`carenlp_db`, without touching it. It does not change who can
start or stop the server — connecting to `carenlp_db_restore` needs
nothing more than the server already being up, exactly like connecting
to `carenlp_db` does today.

Use this document instead when the actual goal is: a different
person needs to be able to manage the server process itself.

## Why a plain restore into the same server can't do this


- Postgres enforces that its data directory be owned by, and only
  accessible to, one specific OS user — `0700` by default. Starting
  the server means writing `postmaster.pid` into that directory, which
  only the owner can do.
- POSIX ACLs — which would otherwise let you grant one specific
  other person real access without changing the owning user or the
  plain Unix mode bits — are not supported on this BeeGFS mount
  (`setfacl: Operation not supported`, confirmed directly).
- Making the directory group-writable with plain `chmod` doesn't work
  either — Postgres itself refuses to start against it:
  ```
  FATAL:  data directory "..." has invalid permissions
  DETAIL:  Permissions should be u=rwx (0700) or u=rwx,g=rx (0750).
  ```

So the only real fix is: the new owner runs `initdb` themselves,
producing a data directory *they* own, with its own server process.
There's no shortcut around this on this cluster.

## Prerequisites

- The new owner has cluster access ([`access-instructions.md`](access-instructions.md))
  and can write somewhere under the shared group folder for their own
  `pgdata` — e.g. a new sibling folder to the existing one, created by
  them (so they own it), such as
  `/net/beegfs/groups/care-nlp-db/carenlp/pgdata_<username>`.
- A completed, verified backup of the live database — run
  [`backup-and-restore.md`](backup-and-restore.md)'s "Backup" section
  (steps 1–4: dump, verify, roles) first if you haven't already. This
  document picks up from that dump file.
- Enough free space for a second copy to exist temporarily, at least
  until the new cluster is verified and the old one is retired — see
  [`troubleshooting.md`](troubleshooting.md)'s note on the storage
  cap. Not addressed further here.
- **The original server must be stopped (`pgstop`) before the new
  owner starts theirs.** Both use the same `/tmp` socket by default
  (matching the existing `pgstart`/`pgstop`/`psqlcarenlp` aliases) —
  two servers can't share the same socket at once. This is fine for a
  one-time transfer (the old one is being retired anyway), just don't
  restart the original at `/tmp` while the new one is running there.

## Steps

### 1. The new owner creates their own, independently-owned cluster

```bash
mkdir -p /net/beegfs/groups/care-nlp-db/carenlp/pgdata_<username>
apptainer exec $SIF initdb -D /net/beegfs/groups/care-nlp-db/carenlp/pgdata_<username> -U postgres
```

This is the step that actually matters: whoever runs `initdb` owns
the resulting directory, and from now on only that owner's OS account
can start or stop a server against it.

### 2. Make sure the original server is stopped, then start the new one

```bash
pgstop   # if the original is still running -- confirm with pgstatus first
```

Then, as the new owner, start a server against the new cluster — using
`/tmp`, same as the existing `pgstart` alias, since the original isn't
using it right now:

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata_<username>:/var/lib/postgresql/data $SIF postgres -D /var/lib/postgresql/data -k /tmp &
```

### 3. Restore roles into the new server

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/backups $SIF psql -h /tmp -U postgres -f /backups/roles_YYYY-MM-DD.sql
```

### 4. Restore the database itself

Same name as the original (`carenlp_db`) this time — this is a
separate, independent server, not a second database sharing the
original one, so there's no collision:

```bash
apptainer exec $SIF createdb -h /tmp -U postgres carenlp_db

apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/backups $SIF pg_restore -h /tmp -U postgres -d carenlp_db /backups/carenlp_db_YYYY-MM-DD.dump
```

### 5. Verify before relying on it

- Row counts on a few key tables match the original (`SELECT count(*)
  FROM amc_core.patient_not_traceable;` and similar, compared against
  the original server).
- A few real queries — e.g. from `cohort-functions/examples.sql` —
  return sane results.
- **The actual thing this was all for**: the new owner stops and
  restarts *their* server themselves, from their own login, with no
  permission errors.

### 6. Once verified

- Decide whether/when to retire the original `pgdata` — frees the
  temporary extra space. Not urgent the moment verification passes;
  do it once you're genuinely confident, not under time pressure.
- Set up `pgstart`/`pgstop`/`psqlcarenlp` aliases for the new owner —
  identical to [`access-instructions.md`](access-instructions.md)'s
  existing ones, just with `$PGDATA_HOST` pointing at their own
  `pgdata_<username>` path instead of the original. `/tmp` stays the
  same since the old cluster is being retired, not run alongside this
  one long-term.
- Update `access-instructions.md` and
  [`handover.md`](handover.md) to name the new owner as the one who
  manages the server going forward.

This fixes who owns the server today, but it's still just one person.

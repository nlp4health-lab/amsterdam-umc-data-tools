# Creating the database in Apptainer on Helios

One-time setup: building the Postgres container, initializing a fresh
data directory on the cluster, and migrating the database over from
MyDRE. You only need this to stand up a new environment from scratch —
for day-to-day start/stop/connect once the database already exists, see
[`access-instructions.md`](access-instructions.md). Steps 7-8 below share their
mechanics with [`backup-and-restore.md`](backup-and-restore.md)'s
restore process.

Commands below use the shared group paths (`SIF`, `PGDATA_HOST`, as
defined in [`access-instructions.md`](access-instructions.md)) rather than a personal
`/net/beegfs/users/<username>/` space, so the result is usable by the
whole `care_nlp_db` group from the start.

## 1. Set up a build tmpdir

Apptainer needs scratch space to build the image:

```bash
export APPTAINER_TMPDIR=/net/beegfs/groups/care-nlp-db/carenlp/apptainer_tmp
mkdir -p "$APPTAINER_TMPDIR"
```

## 2. Build the Postgres container image

```bash
apptainer build /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif docker://postgres:18
```

Verify it landed:

```bash
ls /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif
```

## 3. Create the data directory

```bash
mkdir -p /net/beegfs/groups/care-nlp-db/carenlp/pgdata
chmod 770 /net/beegfs/groups/care-nlp-db/carenlp/pgdata
```

## 4. Initialize Postgres

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  initdb -D /var/lib/postgresql/data
```

## 5. Start the server

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  postgres -D /var/lib/postgresql/data -k /tmp
```

This runs in the foreground and prints the server logs — open a
**second** terminal (or a `tmux` session, so it survives logout) to
continue with the steps below while this one keeps running.

## 6. Create the superuser role and the database

From the second terminal:

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  createuser -h /tmp -U "$USER" -s postgres

apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  createdb -h /tmp -U postgres carenlp_db
```

`createuser` connects as the bootstrap superuser `initdb` created (your
own cluster username) and creates a new superuser role named `postgres`
— every later command connects as that role.

## 7. Restore roles from the MyDRE backup

Bind the folder holding your dump/roles files as `/restore`:

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/restore \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  psql -h /tmp -U postgres -f /restore/roles.sql
```

Verify the database is registered:

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  psql -h /tmp -U postgres -l
```

## 8. Restore the data

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/restore \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  pg_restore -h /tmp -U postgres -d carenlp_db --no-owner --role=postgres \
  /restore/carenlp_db_YYYY-MM-DD.dump
```

Same command shape as [`backup-and-restore.md`](backup-and-restore.md)'s
restore step — this is that process, run once against the MyDRE dump to
seed the new cluster environment.

## 9. Verify

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  psql -h /tmp -U postgres -d carenlp_db -c "SELECT pg_size_pretty(pg_database_size('carenlp_db'));"
```

From here on, use [`access-instructions.md`](access-instructions.md)'s `pgstart` /
`pgstatus` / `psqlcarenlp` / `pgstop` aliases for normal use.

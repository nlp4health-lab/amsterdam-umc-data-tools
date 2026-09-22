# Backup and restore

How to back up `carenlp_db` and restore it, running through the same
Apptainer/Postgres setup as
[`create-database-in-apptainer.md`](create-database-in-apptainer.md)
and [`access-instructions.md`](access-instructions.md).

## Backup

### 1. Create the backup directory

```bash
mkdir -p /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps
```

### 2. Dump the database

Start the server first (`pgstart`, see [`access-instructions.md`](access-instructions.md)), then:

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  pg_dump -h /tmp -U postgres -Fc carenlp_db \
  > /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps/carenlp_db_$(date +%F).dump
```

This produces a compressed (`-Fc`) dump. Last time it took around 2
hours to complete.

### 3. Verify the dump

```bash
ls -lh /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps
```

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/backups \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  pg_restore --list /backups/carenlp_db_YYYY-MM-DD.dump | head
```

### 4. Dump roles too

Roles aren't included in a per-database dump — back them up separately:

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pgdata:/var/lib/postgresql/data \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  pg_dumpall -h /tmp -U postgres --roles-only \
  > /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps/roles_$(date +%F).sql
```

## Restore

### 1. Restore roles

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/backups \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  psql -h /tmp -U postgres -f /backups/roles_YYYY-MM-DD.sql
```

### 2. Create a fresh database

```bash
apptainer exec \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  createdb -h /tmp -U postgres carenlp_db_restore
```

Name it something other than `carenlp_db` (e.g. `carenlp_db_restore`)
unless you specifically intend to overwrite the live database.

### 3. Restore

```bash
apptainer exec -B /net/beegfs/groups/care-nlp-db/carenlp/pg_dumps:/backups \
  /net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif \
  pg_restore -h /tmp -U postgres -d carenlp_db_restore \
  /backups/carenlp_db_YYYY-MM-DD.dump
```

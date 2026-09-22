# docs/instructions

Cluster and database setup — not part of the data pipeline itself.

- **[`access-instructions.md`](access-instructions.md)** — getting
  cluster access, and the day-to-day `pgstart`/`pgstatus`/
  `psqlcarenlp`/`pgstop` workflow for the shared Postgres instance.
  Start here.
- **[`create-database-in-apptainer.md`](create-database-in-apptainer.md)**
  — one-time setup: building the Postgres container, initializing a
  fresh data directory, and migrating a database in from MyDRE. Only
  needed to stand up a new environment from scratch.
- **[`backup-and-restore.md`](backup-and-restore.md)** — backing up
  `carenlp_db` and restoring it from a dump.

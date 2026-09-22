# CARE-NLP Database Access

This document explains how to start, connect to, check, and stop the database running through Apptainer.

## Cluster Helios access

First you need to have access to the cluster. 

To access CARE-NLP database, you need access to the group is **care_nlp_db**.

## Notes on concurrent access

* The PostgreSQL data directory is shared, so only one PostgreSQL server instance can be running at any given time.
* The current setup uses a Unix socket located in `/tmp` which exists only on the local cluster node.
* If two users are logged into the same cluster node (check hostname, mine is always hpcloginresearch01.cluster), they can both connect to the same running PostgreSQL server and use the database simultaneously.
* If users are logged into different cluster nodes, they will not be able to connect to the same server. In that case, the second user will need to wait until the current server is stopped before starting their own PostgreSQL instance.
* (I usually keep the database running inside a tmux session. While I'm on holiday I'll stop it so that anyone can start it if needed.)
  

Before starting the database, check whether a server is already running:

```bash
pgstatus
```

* If the server is not running, start it with:

```bash
pgstart
```

* If `pgstatus` reports that the server is already running, don't run `pgstart` again. Instead, if the existing server is accessible from your node, connect to it using:

```bash
psqlcarenlp
```

## Database location

Group folder:

```bash
/net/beegfs/groups/care-nlp-db/
```

## Environment variables

Add the following to your shell (or your `.bashrc` if you use it frequently):

```bash
export SIF=/net/beegfs/groups/care-nlp-db/carenlp/containers/postgre18.sif

export PGDATA_HOST=/net/beegfs/groups/care-nlp-db/carenlp/pgdata

export CSV_HOST=/net/beegfs/groups/care-nlp-db/carenlp/scripts
```

`CSV_HOST` is always the shared `scripts` folder — the same convention
`structured-refresh/README.md` and `refresh.sh` use, not a personal
scratch directory. This is also where `structured-refresh/07_metadata`'s
CSVs (`data_dictionary.csv`, `name_mapping.csv`) already live.

## Useful aliases

```bash
alias pgstart='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data $SIF postgres -D /var/lib/postgresql/data -k /tmp'

alias pgstatus='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data $SIF pg_ctl -D /var/lib/postgresql/data status'

alias psqlcarenlp='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data -B ${CSV_HOST}:/csv $SIF psql -h /tmp -U postgres -d carenlp_db'

alias pgstop='apptainer exec -B ${PGDATA_HOST}:/var/lib/postgresql/data $SIF pg_ctl -D /var/lib/postgresql/data stop -m fast'
```

## Typical workflow

### 1. Start the database

```bash
pgstart
```

This command starts the PostgreSQL server.

---

### 2. Verify that it is running

```bash
pgstatus
```

You should see something similar to:

```text
pg_ctl: server is running (PID: xxxx)
```

---

### 3. Connect to the database

```bash
psqlcarenlp
```

You should now see the PostgreSQL prompt:

```text
carenlp_db=#
```

You can now execute SQL queries.

---

### 4. Exit PostgreSQL

When finished, type:

```sql
\q
```

This returns you to your shell.

---

### 5. Stop the database

Once you're done working:

```bash
pgstop
```
This cleanly shuts down the PostgreSQL server.

## Summary

```text
pgstart      # Start PostgreSQL
pgstatus     # Check whether it is running
psqlcarenlp  # Connect to the CARE-NLP database
\q           # Exit PostgreSQL
pgstop       # Stop PostgreSQL
```
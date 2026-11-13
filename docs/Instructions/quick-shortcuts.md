# Quick reference: exploring the database, and tmux

Common day-to-day commands 

## Exploring the database

Run these inside `psql` (after `psqlcarenlp`):

```sql
\dt amc_core.*               -- list tables
\dv amc_views.*              -- list views
\df cohort_functions.*       -- list functions
\dn                          -- list schemas
```

```sql
\d amc_views.v_clinical_timeline    -- describe one object: its columns and types
\d+ amc_core.lab_result             -- same, plus storage/size details
```

This repo also has its own metadata catalog, worth checking before
digging through a view's SQL by hand:

```sql
SELECT * FROM meta.catalog WHERE object_name = 'v_clinical_timeline';
SELECT * FROM meta.view_dependencies WHERE view_name = 'v_clinical_timeline';
SELECT * FROM meta.data_dictionary WHERE table_name = 'lab_result';
```

## tmux (keep a long-running command alive after you disconnect)

Anything that might outlast your SSH session — a `pg_dump`, a
`pg_restore`, a long `structured-refresh/refresh.sh` run — belongs
inside a named `tmux` session, not run directly in your terminal.

```bash
tmux new -s mysession        # start a new, named session
```
Run your actual command(s) inside it as normal.

**Multiple windows inside the same session** — useful for running one
command while keeping an eye on something else (e.g. a restore in one
window, `tail -f` a log, or just your normal shell, in another):

```
Ctrl+b, then c      -- create a new window in this session
Ctrl+b, then n      -- switch to the next window
Ctrl+b, then p      -- switch to the previous window
Ctrl+b, then <0-9>  -- jump straight to window number 0-9
```
Each is two separate keypresses, not held together — press `Ctrl+b`,
release, then press the letter/number. These new windows are part of
the *same* session, so detaching (`Ctrl+b` then `d`) takes all of them
with it, and reattaching brings all of them back.

```bash
# detach without stopping anything: Ctrl+b, then d (two separate keypresses)
tmux ls                       # list all your sessions (see what's still running)
tmux attach -t mysession       # reattach to a session you detached from earlier
tmux kill-session -t mysession # end a session for good (stops whatever was running in it)
```


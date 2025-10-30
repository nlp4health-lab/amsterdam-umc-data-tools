## How to Use the Database

### 1. Connect to the server
myDRE → CaRe-NLP → dws3547AUCareNLserver1

### 2. Start and access the Docker container
```bash
docker start carenlp
docker exec -it carenlp psql -U postgres -d carenlp_db
```

You’re now inside the PostgreSQL database and can start writing queries.

### 3. Useful PostgreSQL commands

| Command | Description |
|----------|-------------|
| `\dt` | List all tables |
| `\d table_name` | Show table schema |
| `\d+ table_name` | Show detailed table info |
| `\dv` | List all views |
| `\q` | Quit psql |

### 4. Export query results to CSV
You can save the results of a query as a CSV file:

```sql
\copy (SELECT * FROM your_table LIMIT 100) TO '/path/to/output.csv' WITH CSV HEADER;
```

### 5. Exit
```bash
\q
docker stop carenlp
```

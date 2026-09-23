# Technical Test – Rayhan Kimi Nabiel Athallah

The full explanation of every answer (design, decisions, limitations) is located in presentation as PPTX/PDF with file named **answer.pdf** and **answer.pptx**. This README only covers the project layout and how to run each part.

## Requirements

Docker with the Compose plugin. 

## Project structure

```
.
├── .github/
│   ├── sc/semver.sh            # Versioning helper for the pipeline
│   └── workflows/workflow.yaml # GitHub Actions pipeline
├── app/                        # Q1: FastAPI backend
│   ├── fe/
│   │   ├── nginx.conf          # Serves the frontend, proxies /api/* to the API
│   │   └── public/index.html   # Frontend
│   ├── main.py                 # App and endpoints
│   ├── schemas.py              # Request/response models
│   └── time.py                 # Timezone helpers
├── q2/                         # Q2: snapshot cron job
│   ├── Dockerfile              # Scheduler image (Alpine + crond)
│   ├── crontab                 # Schedule
│   ├── snapshot.sh             # Saves a CSV snapshot
│   ├── cleanup.sh              # Deletes snapshots older than 30 days
│   └── snapshots/              # CSV output (mounted into the container)
├── q3/                         # Q3: SQL
│   ├── init/
│   │   ├── schema.sql          # Tables (runs automatically on first start)
│   │   └── seed.sql            # Sample data from the question
│   ├── answers.sql             # The five answers
│   └── q3.sh                   # Runs answers.sql against the database
├── Dockerfile                  # Q1 API image
├── docker-compose.yaml         # api, web, scheduler, db
└── requirements.txt
```

## Technical test answer and solution 

Answer, solution, explanation, and deciding factor is written in **answer.pdf** and **answer.pptx** file.

## Start and stop

```bash
docker compose up -d --build --wait   # start everything
docker compose down                   # stop
```

## Q1: Subscriber Usage API

- Frontend: http://localhost:8080
- API: http://localhost:8000
- Swagger: http://localhost:8000/docs

```bash
# Record usage
curl -X POST http://localhost:8000/usages \
  -H "Content-Type: application/json" \
  -d '{"subscriberId":"SUB01","callMinutes":40,"smsCount":10,"dataUsageMB":1500}'

# Retrieve usage (all filters optional; times without an offset are treated as WIB)
curl "http://localhost:8000/usages?subscriberId=SUB01&from=2026-09-23T08:00&to=2026-09-23T12:00"
```

## Q2: Snapshot cron job

Runs automatically in the `scheduler` container: snapshots at 08:00, 12:00 and 15:00 WIB, cleanup daily at 00:30 WIB. Files are written to `q2/snapshots/` as `usage_snapshot_YYYYMMDD_HHMM_WIB.csv`.

Run manually instead of waiting for the schedule:

```bash
# Snapshot for the most recent slot
docker compose exec scheduler /app/snapshot.sh

# Snapshot for a specific slot (use the next slot after now to include records just created)
docker compose exec -e SNAPSHOT_AT="2026-09-23 12:00" scheduler /app/snapshot.sh

# Cleanup: preview first, then delete
docker compose exec -e DRY_RUN=1 scheduler /app/cleanup.sh
docker compose exec scheduler /app/cleanup.sh

# Job output
docker compose logs scheduler
```

## Q3: SQL

The database starts with the stack and loads the schema and sample data automatically.

```bash
./q3/q3.sh
```

`answers.sql` runs inside a transaction that is rolled back, so the script can be run repeatedly. To rebuild the database from `q3/init`:

```bash
docker compose up -d --force-recreate -V db
```

## Q4: Debugging

Written answer (root cause, fix, prevention) is in the answer.pdf and answer.pptx file.
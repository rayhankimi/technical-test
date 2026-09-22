from fastapi import FastAPI
from datetime import datetime, timezone

from app.schemas import UsageRecord, UsageCreate

app = FastAPI(title="Subscriber Usage App")

usages: list[UsageRecord] = []  # only uses In memory storage

@app.get("/health")
def health():
    return { "status" : "ok" }

@app.post("/usages")
def create_usage(payload: UsageCreate):
    record = UsageRecord(
        id=len(usages) + 1,
        timestamp=datetime.now(timezone.utc),
        **payload.model_dump()
    )
    usages.append(record)
    return record

@app.get("/usages", response_model=list[UsageRecord])
def list_usages():
    return usages


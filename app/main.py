import threading
from itertools import count

from fastapi import FastAPI, Query
from datetime import datetime, timezone

from app.schemas import UsageRecord, UsageCreate
from app.time import to_aware

app = FastAPI(title="Subscriber Usage App")

usages: list[UsageRecord] = []  # only uses In memory storage
_lock = threading.Lock()
_ids = count(1)

@app.get("/health")
def health():
    return { "status" : "ok" }

@app.post("/usages")
def create_usage(payload: UsageCreate):

    # to avoid race condition for id
    with _lock:
        record = UsageRecord(
            id=next(_ids),
            timestamp=datetime.now(timezone.utc),
            **payload.model_dump()
        )
        usages.append(record)
    return record

@app.get("/usages", response_model=list[UsageRecord])
def list_usages(
        subscriberId: str | None = None,
        start: datetime | None = Query(None, alias="from"),
        end: datetime | None = Query(None, alias="to"),
):
    result = usages
    if subscriberId:
        result = [u for u in result if u.subscriberId == subscriberId]
    if start:
        result = [u for u in result if u.timestamp >= to_aware(start)]
    if end:
        result = [u for u in result if u.timestamp <= to_aware(end)]
    return result


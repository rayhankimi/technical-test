from datetime import datetime
from pydantic import BaseModel, Field


class UsageCreate(BaseModel):
    subscriberId: str = Field(min_length=1)
    callMinutes: int = Field(ge=0)
    smsCount: int = Field(ge=0)
    dataUsageMB: float = Field(ge=0)

class UsageRecord(UsageCreate):
    id: int
    timestamp: datetime
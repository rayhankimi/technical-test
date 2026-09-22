from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class UsageCreate(BaseModel):
    subscriberId: str = Field(min_length=1)
    callMinutes: int = Field(ge=0)
    smsCount: int = Field(ge=0)
    dataUsageMB: float = Field(ge=0)
    model_config = ConfigDict(strict=True, extra="forbid", str_strip_whitespace=True)


class UsageRecord(UsageCreate):
    id: int
    timestamp: datetime

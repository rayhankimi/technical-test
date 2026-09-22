from datetime import datetime, timedelta, timezone

WIB = timezone(timedelta(hours=7))


def to_aware(dt: datetime) -> datetime:
    return dt if dt.tzinfo else dt.replace(tzinfo=WIB)

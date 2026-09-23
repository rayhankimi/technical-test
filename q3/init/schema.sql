ALTER DATABASE postgres SET timezone TO 'Asia/Jakarta';

CREATE TABLE subscribers (
    id              VARCHAR(20)  PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    plan            VARCHAR(20)  NOT NULL
                    CHECK (plan IN ('Basic', 'Premium', 'Family')),
    activation_date DATE         NOT NULL
);

CREATE TABLE usage (
    id            BIGSERIAL     PRIMARY KEY,
    subscriber_id VARCHAR(20)   NOT NULL REFERENCES subscribers (id),
    call_minutes  INTEGER       NOT NULL CHECK (call_minutes >= 0),
    sms_count     INTEGER       NOT NULL CHECK (sms_count >= 0),
    data_usage_mb NUMERIC(12,2) NOT NULL CHECK (data_usage_mb >= 0),
    recorded_at   TIMESTAMPTZ   NOT NULL
);

CREATE INDEX usage_subscriber_id_idx ON usage (subscriber_id);
FROM alpine:3.22

RUN apk add --no-cache bash curl jq tzdata coreutils

# run on utc+7 (wib)
ENV TZ=Asia/Jakarta

WORKDIR /app
COPY snapshot.sh cleanup.sh ./
RUN chmod 755 snapshot.sh cleanup.sh && mkdir -p /data/snapshots
COPY crontab /etc/crontabs/root

# BusyBox crond must runs as root
CMD ["crond", "-f", "-l", "2", "-L", "/dev/stderr"]

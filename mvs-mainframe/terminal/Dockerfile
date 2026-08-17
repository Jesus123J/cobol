FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends c3270 s3270 \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["c3270"]
CMD ["mvs:3270"]

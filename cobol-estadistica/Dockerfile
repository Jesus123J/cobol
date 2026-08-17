FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnucobol4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY src/ src/
COPY data/ data/

RUN cobc -x -free -O2 src/estadistica.cbl -o estadistica

CMD ["./estadistica"]

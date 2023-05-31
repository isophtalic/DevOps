FROM ubuntu:22.04 AS runtime
RUN mkdir /app
WORKDIR /app
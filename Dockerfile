FROM ubuntu:22.04 AS runtime
RUN mkdir /app
WORKDIR /app
COPY pf.conf /app/
COPY performance.sh /app/
RUN apt update
RUN apt install bc -y
RUN apt install curl -y
RUN bash -c "chmod +x /app/performance.sh"

CMD [ "./performance.sh" ]

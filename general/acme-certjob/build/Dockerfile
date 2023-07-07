FROM bitnami/kubectl:1.20 AS kubectl

FROM debian:10-slim AS main
WORKDIR /data
COPY . .
COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /bin/kubectl

RUN apt update
RUN apt install wget -y
RUN /data/acme.sh install --force
RUN /root/.acme.sh/acme.sh --upgrade

ENTRYPOINT "/data/entrypoint.sh"
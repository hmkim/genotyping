FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    --no-install-recommends

ARG PLINK_URL=https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20241022.zip

RUN wget --no-check-certificate $PLINK_URL -O plink.zip && \
    unzip plink.zip && \
    chmod +x plink && \
    mv plink /usr/local/bin && \
    rm plink.zip

RUN plink --version

WORKDIR /data

CMD ["/bin/bash"]

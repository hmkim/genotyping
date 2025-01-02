FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    tar \
    wget libicu-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Illumina CLI 2.1.0
COPY array-analysis-cli-linux-x64-v2.1.0.tar.gz .

RUN gzip -d array-analysis-cli-linux-x64-v2.1.0.tar.gz && \
    tar -xvf array-analysis-cli-linux-x64-v2.1.0.tar && \
    mv array-analysis-cli-linux-x64-v2.1.0/ /usr/local/bin/ && \
    rm array-analysis-cli-linux-x64-v2.1.0.tar 
ENV PATH="/usr/local/bin/array-analysis-cli-linux-x64-v2.1.0/array-analysis-cli:$PATH" 

#CMD ["array-analysis-cli"]

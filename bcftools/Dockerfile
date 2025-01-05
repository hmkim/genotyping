# Use a lightweight base image with pre-installed bioinformatics tools
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        build-essential \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev \
        libcurl4-openssl-dev \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the bcftools version
ENV BCFTOOLS_VERSION=1.21

# Download and install bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    tar -xjf bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    cd bcftools-${BCFTOOLS_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd .. && \
    rm -rf bcftools-${BCFTOOLS_VERSION} bcftools-${BCFTOOLS_VERSION}.tar.bz2

# Download and install htslib for bgzip and tabix
RUN wget https://github.com/samtools/htslib/releases/download/${BCFTOOLS_VERSION}/htslib-${BCFTOOLS_VERSION}.tar.bz2 && \
    tar -xjf htslib-${BCFTOOLS_VERSION}.tar.bz2 && \
    cd htslib-${BCFTOOLS_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd .. && \
    rm -rf htslib-${BCFTOOLS_VERSION} htslib-${BCFTOOLS_VERSION}.tar.bz2

# Default command
CMD ["bcftools"]


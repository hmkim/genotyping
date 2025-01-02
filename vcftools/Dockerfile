FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    git \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    pkg-config && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt

# Clone the vcftools repository
RUN git clone https://github.com/vcftools/vcftools.git && cd vcftools && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# Clean up
RUN rm -rf /var/lib/apt/lists/* /opt/vcftools

# Verify installation
RUN vcftools --version

# Set entrypoint to vcftools
ENTRYPOINT ["vcftools"]


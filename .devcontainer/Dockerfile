FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install toolchain dependencies at image build time for faster container startup.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        git \
        lua5.2 \
        make \
        zip \
    && rm -rf /var/lib/apt/lists/*

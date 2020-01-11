FROM debian:10

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

RUN apt-get -y install git procps lsb-release

RUN apt-get -y install ruby2.5 build-essential zlib1g-dev
RUN gem install jekyll bundler

# Clean up
#RUN apt-get autoremove -y \
#    && apt-get clean -y \
#    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

ENV SHELL /bin/bash

FROM debian:10

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1

RUN apt-get -y install git procps lsb-release

RUN apt-get -y install curl build-essential zlib1g-dev ruby-full
#RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && curl -sSL https://get.rvm.io | bash -s stable --ruby
RUN gem install jekyll bundler

# Clean up
#RUN apt-get autoremove -y \
#    && apt-get clean -y \
#    && rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=dialog

ENV SHELL /bin/bash

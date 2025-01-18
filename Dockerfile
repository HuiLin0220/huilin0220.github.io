FROM bitnami/minideb:latest

LABEL maintainer="Amir Pourmand"

# Update and install essential dependencies
RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
    locales \
    git \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    imagemagick \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure locales for en_US.UTF-8
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
    /tmp/ruby-build/install.sh && \
    rm -rf /tmp/ruby-build

# Use ruby-build to install Ruby (version 3.1.4)
RUN ruby-build 3.1.4 /usr/local/ruby-3.1.4

# Add Ruby to the PATH environment variable
ENV PATH="/usr/local/ruby-3.1.4/bin:$PATH"

# Verify Ruby installation
RUN ruby --version && gem --version

# Install Jekyll and Bundler gems
RUN gem install jekyll bundler

# Install Python dependencies
RUN python3 -m pip install --no-cache-dir jupyter --break-system-packages

# Create and configure Jekyll working directory
RUN mkdir -p /srv/jekyll
ADD Gemfile /srv/jekyll
WORKDIR /srv/jekyll

# Install Jekyll dependencies using Bundler
RUN bundle install

# Set Jekyll environment to production
ENV JEKYLL_ENV=production

# Expose port 8080 for the Jekyll server
EXPOSE 8080

# Command to start the Jekyll server
CMD ["/bin/bash", "-c", "rm -f Gemfile.lock && exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace"]

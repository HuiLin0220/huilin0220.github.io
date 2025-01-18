FROM bitnami/minideb:latest

Label MAINTAINER Amir Pourmand

RUN apt-get update -y

# add locale
RUN apt-get -y install locales
# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# add ruby and jekyll


# Install ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git /tmp/ruby-build && \
    /tmp/ruby-build/install.sh && \
    rm -rf /tmp/ruby-build

# Use ruby-build to install Ruby (e.g., version 3.1.4)
RUN ruby-build 3.1.4 /usr/local/ruby-3.1.4

# Add Ruby to the PATH
ENV PATH="/usr/local/ruby-3.1.4/bin:$PATH"

# Mark the Ruby installation as complete (optional if using workflows)
RUN ruby --version && gem --version

RUN apt-get install imagemagick -y

# install python3 and jupyter
RUN apt-get install python3-pip -y
RUN python3 -m pip install jupyter --break-system-packages

# install jekyll and dependencies
RUN gem install jekyll bundler

RUN mkdir /srv/jekyll

ADD Gemfile /srv/jekyll

WORKDIR /srv/jekyll

RUN bundle install

# Set Jekyll environment
ENV JEKYLL_ENV=production 

EXPOSE 8080

CMD ["/bin/bash", "-c", "rm -f Gemfile.lock && exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace"]

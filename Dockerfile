FROM ruby:2.2.0
ADD . /drydocker
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 \
  && echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
RUN apt-get -yq update && apt-get -yq upgrade
RUN apt-get -yq install lxc-docker-1.4.1
WORKDIR /drydocker
RUN bundle install
#RUN bundle exec rspec spec
RUN bundle exec rake build:gem
RUN bundle exec gem install pkg/drydocker*.gem
WORKDIR /app
CMD drydocker

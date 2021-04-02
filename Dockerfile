FROM node:lts-alpine as node
FROM yyachi/ruby-fits:2.7.2-alpine as ruby-fits 
FROM ruby:2.7.2-alpine as builder
RUN apk --update --no-cache add \
build-base \
bash \
git \
tzdata \
shared-mime-info \
postgresql-dev \
python3 \
py3-pip

WORKDIR /medusa
COPY Gemfile Gemfile.lock ./

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn-v1.22.5 /opt/yarn
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

RUN gem install bundler --version 2.2.8 && \
    bundle install --without development test --path vendor/bundler
#    find vendor/bundle/ruby -path '*/gems/*/ext/*/Makefile' -exec dirname {} \; | xargs -n1 -P$(nproc) -I{} make -C {} clean

COPY package.json yarn.lock ./
RUN yarn install && yarn cache clean
#COPY Rakefile ./
#COPY app/webpack app/webpack
#COPY app/assets app/assets
#COPY bin bin
#COPY config config
COPY . /medusa
RUN RAILS_ENV=production bundle exec rake assets:precompile

ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} medusa && adduser -h /medusa -s /bin/bash -G medusa -u ${UID} --disabled-password medusa \
 && chown -R medusa:medusa /medusa

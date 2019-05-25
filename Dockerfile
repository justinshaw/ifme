# Dockerfile
FROM ruby:2.6-alpine

ENV PORT 3000
ENV PATH /node_modules/.bin:$PATH
ENV BUNDLER_VERSION 1.17.3

RUN apk update && apk add \
    bash \
    nodejs \
    curl \
    npm \
    build-base \
    postgresql-client \
    postgresql-dev \
    tzdata \
  && npm install --global yarn \
  && mkdir "/node_modules" \
  && echo "--install.modules-folder /node_modules" > /.yarnrc

# Install wait-for-it
RUN (cd /usr/local/bin && curl --silent -O \
     https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
     chmod +x wait-for-it.sh && mv wait-for-it.sh wait-for-it)

WORKDIR /app

# add gems and npm packages before our code, so Docker can cache them
# see http://ilikestuffblog.com/2014/01/06/
COPY Gemfile Gemfile.lock package.json ./
COPY client/package.json client/yarn.lock ./client/

RUN bundle install && npm install

RUN bundle exec rake assets:precompile

CMD ["foreman", "start", "-f", "Procfile.dev"]
EXPOSE ${PORT}

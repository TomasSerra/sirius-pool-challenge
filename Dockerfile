FROM ruby:3.2.0

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    postgresql-client

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install --without development test

COPY . .

RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD ["sh", "-c", "cp /etc/secrets/master.key config/master.key && bundle exec puma -C config/puma.rb"]
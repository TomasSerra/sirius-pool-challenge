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

RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

CMD ["sh", "-c", "echo \"$RAILS_MASTER_KEY\" > config/master.key && bundle exec puma -C config/puma.rb"]

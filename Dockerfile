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

ENV RAILS_ENV=production

COPY . .

RUN echo "$RAILS_MASTER_KEY" > config/master.key

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "--debug"]
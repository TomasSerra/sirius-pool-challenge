# Usar la imagen base de Ruby
FROM ruby:3.2.0

# Instalar dependencias necesarias
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    postgresql-client

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de Gemfile
COPY Gemfile Gemfile.lock ./

# Instalar las dependencias de Ruby
RUN bundle install --without development test

# Copiar el resto del código
COPY . .

RUN echo "$MASTER_KEY" > config/master.key

# Instalar dependencias de Yarn
RUN yarn install

# Precompilar assets
RUN bundle exec rake assets:precompile

# Exponer el puerto 3000
EXPOSE 3000

# Comando de inicio
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
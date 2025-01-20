source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]


# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"
gem "active_model_serializers"

gem "azure-blob"

gem "dotenv-rails"

# Swagger
gem "rswag"
gem "rswag-ui"
gem "rswag-api"
gem "rswag-specs"
gem "rspec-rails"

gem "overcommit"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # Use the database-backed adapters for Rails.cache
  gem "solid_cache"
  # Active Cable and Active Jobs
  gem "solid_cable"
  gem "solid_queue"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false

  gem "factory_bot_rails"
  gem "faker"
end

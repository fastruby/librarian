source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "4.0.10"

def next?
  File.basename(__FILE__) == "Gemfile.next"
end

gem "next_rails"

# Removed from default gems in Ruby 3.4+/4.0
gem "csv"
gem "mutex_m"
gem "nkf"
gem "observer"
gem "ostruct"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
if next?
  gem "rails", github: "rails/rails", branch: "main"
else
  gem "rails", "~> 8.1.0"
end

# Application Dependencies
gem "dotenv-rails"
gem "mechanize"
gem "sitemap-parser"
gem "ombu_labs-shortener"
gem "ombu_labs-auth"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
gem "tailwindcss-rails", "~> 3.3"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 8.1"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end


group :development do
  gem "guard-rspec", require: false
end

group :test do
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  if next?
    gem "rspec-rails", github: "rspec/rspec-rails", branch: "main"
  else
    gem "rspec-rails"
  end
end

group :development, :test do
  gem "rails-controller-testing"
  gem "factory_bot_rails"
  gem "simplecov", require: false
  gem "standard"
  gem "rubocop-rspec"
  gem "rubocop-rails"
  gem "reek"
  gem "overcommit", "0.57.0"
end
gem "dotenv_validator"
gem "pagy"

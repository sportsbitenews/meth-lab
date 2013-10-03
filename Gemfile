source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'mysql2'
# gem 'mina'
gem 'hiredis', '=0.4.5'
gem 'redis', '=3.0.2', :require => "redis/connection/hiredis"
gem 'abanalyzer'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  # gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'resque'
gem "resque-async-method"
gem 'hoptoad_notifier'
gem 'unicorn'

# rails a/b testing
gem 'lacmus', :git => 'git@github.com:fiverr/lacmus.git', :tag => 'v0.2.9'
# gem 'lacmus', :path => '../lacmus/'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
group :development do
# To use debugger
 	gem 'debugger'
 	gem 'pry'
	gem 'pry-remote'
  gem 'pry-stack_explorer'
  gem 'pry-debugger'
 	gem 'better_errors'
end

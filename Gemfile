# If you need to 'vendor your gems' for deploying your daemons, bundler is a
# great option. Update this Gemfile with any additional dependencies and run
# 'bundle install' to get them all installed. Daemon-kit's capistrano
# deployment will ensure that the bundle required by your daemon is properly
# installed.
#
# For more information on bundler, please visit http://gembundler.com

source :gemcutter

# daemon-kit
gem 'daemon-kit'
gem 'eventmachine'
gem 'em-websocket'
gem 'em-http-request'
gem 'cucumber'
gem 'capistrano'
gem 'capistrano-ext'

# safely (http://github.com/kennethkalmer/safely)
gem 'safely'
# gem 'toadhopper' # For reporting exceptions to hoptoad
# gem 'mail' # For reporting exceptions via mail
group :development, :test do
  gem 'rake'
end

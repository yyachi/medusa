# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rbenv'

set :rbenv_type, :user
set :rbenv_ruby, '2.1.7'

require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require "whenever/capistrano"
require "capistrano/sidekiq"
require "capistrano-db-tasks"
require "capistrano/yarn"
# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

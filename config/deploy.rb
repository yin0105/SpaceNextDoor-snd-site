# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.10.1'

set :application, 'snd'
set :repo_url, 'git@git.5xruby.tw:snd/SND.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/settings.yml', 'tmp/restart.txt'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'node_modules'

# Default value for default_env is {}
# set :default_env, path: "/usr/local/ruby26/bin:$PATH"

# restart
set :passenger_restart_with_touch, true

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

before 'deploy:compile_assets', 'install_node_packages' do
  on roles(:web) do
    within release_path do
      execute 'yarn', 'install', '--production'
    end
  end
end

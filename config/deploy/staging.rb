# frozen_string_literal: true

set :rails_env, :staging
set :branch, 'develop'
set :deploy_to, '/srv/app/'
role :app, 'deploy@10.53.0.53'
role :web, 'deploy@10.53.0.53'
role :db, 'deploy@10.53.0.53'

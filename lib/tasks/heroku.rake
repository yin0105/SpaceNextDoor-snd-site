# frozen_string_literal: true

namespace :heroku do
  desc 'Setup heroku buildpacks'
  task :setup, [:app] do |_, args|
    app = args[:app].nil? ? '' : "--app #{args[:app]}"
    sh 'heroku buildpacks:clear'
    sh 'heroku buildpacks:set heroku/ruby' + app
    sh 'heroku buildpacks:add --index 1 heroku/nodejs' + app
  end
end

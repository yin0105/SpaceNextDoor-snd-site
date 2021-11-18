# frozen_string_literal: true

namespace :styleguide do
  desc 'Setup StyleGuid environment'
  task :setup do
    sh 'npm install devbridge-styleguide -g'
    sh 'npm install'
  end

  desc 'Start StyleGuide API Server'
  task :start do
    sh 'npm run guide'
  end
end

# frozen_string_literal: true

namespace :assets do
  desc 'Remove install files'
  task rm_unuse_files: :environment do
    remove_node_modules
    remove_wkhtmltopdf_binary
  end

  desc 'Install mjml'
  task install_mjml: :environment do
    Rails.logger.info 'Install mjml'
    # prefer use npm install -g . ref: https://github.com/sighmon/mjml-rails
    sh 'npm install -g mjml@^4.6.3'
  end
end

def remove_node_modules
  Rails.logger.info 'Removing node_modules folder'
  FileUtils.remove_dir('node_modules', true)
end

def remove_wkhtmltopdf_binary
  # /app/vendor/bundle/ruby/2.6.0/gems/wkhtmltopdf-binary-0.12.6.3
  Rails.logger.info 'Removing unuse wkhtmltopdf_binary gz file'
  path = `bundle show wkhtmltopdf-binary`
  regex = %r{vendor\/.*}
  original_file_path = Rails.root.join(path.slice(regex, 0), 'bin/wkhtmltopdf_ubuntu_18.04_amd64.gz')
  mv_file_path = Rails.root.join(path.slice(regex, 0), 'wkhtmltopdf_ubuntu_18.04_amd64.gz')

  # movev specified file to tmp path
  FileUtils.mv(original_file_path, mv_file_path)

  list = Dir.glob(Rails.root.join(path.slice(regex, 0), 'bin/*.gz'))
  Rails.logger.info "File size: #{list.size}"
  FileUtils.rm_rf(list)
  # move specified file back to original path
  FileUtils.mv(mv_file_path, original_file_path)
end

skip_clean = %w[no false n f].include?(ENV['WEBPACKER_PRECOMPILE'])

unless skip_clean
  if Rake::Task.task_defined?('assets:clean')
    Rake::Task['assets:clean'].enhance do
      Rake::Task['assets:rm_unuse_files'].invoke
      Rake::Task['assets:install_mjml'].invoke
    end
  else
    Rake::Task.define_task('assets:clean' => 'assets:rm_unuse_files')
  end
end

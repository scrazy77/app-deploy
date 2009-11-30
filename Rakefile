# encoding: utf-8

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'app-deploy/version'

Bones{
  name    'app-deploy'
  url     'http://github.com/godfat/app-deploy'
  version AppDeploy::VERSION

  authors 'Lin Jen-Shin (aka godfat 真常)'
  email   'godfat (XD) godfat.org'
  rubyforge.name 'ludy'

  history_file   'CHANGES'
   readme_file   'README'
   ignore_file   '.gitignore'
  rdoc.include   ['\w+']
}

CLEAN.include Dir['**/*.rbc']

task :default do
  Rake.application.options.show_task_pattern = /./
  Rake.application.display_tasks_and_comments
end


namespace :app do

  desc 'install this application'
  task :install => 'install:default'

  namespace :install do
    desc 'before install hook for you to override'
    task :before

    desc 'after install hook for you to override'
    task :after

    task :default => [:before, 'git:clone', 'gem:install', :after]

  end # of install
end # of app


namespace :app do

  desc 'deploy to master state'
  task :deploy => 'deploy:default'

  namespace :deploy do
    desc 'before deploy hook for you to override'
    task :before

    desc 'after deploy hook for you to override'
    task :after

    task :default => [:before, 'git:stash',
                               'server:restart', :after]

  end # of deploy
end # of app

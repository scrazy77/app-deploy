
namespace :app do

  desc 'generic git cmd walk through all dependency'
  task :git, [:cmd] do |t, args|
    cmd = args[:cmd] || 'status'

    puts "Invoking git #{cmd}..."
    begin
      Kernel::system "git #{cmd}"
    rescue RuntimeError => e
      puts e
    end

    AppDeploy.each(:github){ |opts|
      puts "Invoking git #{cmd} on #{opts[:github_project]}..."
      begin
        Kernel::system "git #{cmd}"
      rescue RuntimeError => e
        puts e
      end
    }

  end

  namespace :git do

    task :reset => :stash

    desc 'make anything reflect master state'
    task :stash do
      puts 'Stashing...'
      Kernel::system 'git stash'
    end

    desc 'init and update submodule'
    task :submodule do
      Kernel::system 'git submodule init'
      Kernel::system 'git submodule update'
    end

    desc 'clone repoitory from github'
    task :clone do
      AppDeploy.github.each{ |dep|
        puts "Cloning #{dep[:github_project]}..."
        AppDeploy.clone(dep)
      }
    end

    desc 'pull anything from origin'
    task :pull do
      puts 'Pulling...'
      begin
        Kernel::system 'git pull' if `git remote` =~ /^origin$/
      rescue RuntimeError => e
        puts e
      end

      AppDeploy.each(:github){ |opts|
        puts "Pulling #{opts[:github_project]}..."
        Kernel::system 'git pull'
      }
    end

  end # of git
end # of app


namespace :app do
  namespace :remote do
    task :install, [:hosts, :git, :cd, :branch, :script] do |t, args|
      unless [args[:hosts], args[:git]].all?
        puts 'please fill your arguments like:'
        puts "  > rake app:remote:install[#{args.names.join(',').upcase}]"
        exit(1)
      end

      cd     = args[:cd]     || '~'
      branch = args[:branch] || 'master'
      tmp    = "app-deploy-#{Time.now.to_i}"

      chdir = "cd #{cd}"
      clone = "git clone #{args[:git]} /tmp/#{tmp}"
      setup = "find /tmp/#{tmp} -maxdepth 1 '!' -name #{tmp} -exec mv -f '{}' #{cd} ';'"
      rmdir = "rmdir /tmp/#{tmp}"
      check = "git checkout #{branch}"

      script = "#{chdir}; #{clone}; #{setup}; #{rmdir}; #{check}; #{args[:script]}"
      Rake::Task['app:remote:sh'].invoke(args[:hosts], script)
    end

    desc 'invoke a shell script on remote machines'
    task :sh, [:hosts, :script] do |t, args|
      args[:hosts].split(',').map{ |host|
        script = args[:script].gsub('"', '\\"')
        Thread.new{ Kernel::system "ssh #{host} \"#{script}\"" }
      }.each(&:join)
    end

    desc 'upload a file to remote machines'
    task :upload, [:file, :hosts, :path] do |t, args|
      args[:hosts].split(',').each{ |host|
        Kernel::system "scp #{args[:file]} #{host}:#{args[:path]}"
      }
    end

    desc 'create a user on remote machines'
    task :useradd, [:user, :hosts, :script] do |t, args|
      useradd = "sudo useradd -m #{args[:user]}"
      args[:hosts].split(',').each{ |host|
        script = "#{useradd}; #{args[:script]}".gsub('"', '\\"')
        Kernel::system "ssh #{host} \"#{script}\""
      }
    end

    desc 'upload a tarball and untar to user home, then useradd'
    task :setup, [:user, :file, :hosts, :script] do |t, args|
      path = "/tmp/app-deploy-#{Time.now.to_i}"
      Rake::Task['app:remote:upload'].invoke(
        args[:file], args[:hosts], path)

      script = "sudo -u #{args[:user]} tar -zxf #{path}" +
                   " -C /home/#{args[:user]};"           +
               " rm #{path}; #{args[:script]}"
      Rake::Task['app:remote:useradd'].invoke(
        args[:user], args[:hosts], script)
    end

  end # of remote
end

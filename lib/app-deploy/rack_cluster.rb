
module AppDeploy

  module RackCluster
    module_function
    def each path
      config_orig = {}
      rack_opts = AppDeploy.extract_config(path){ |opt, value|
        case opt
          when 'environment'
            "--env #{value}"

          when *%w[server host]
            config_orig[opt.to_sym] = value
            "--#{opt} #{value}"

          when *%w[user group chdir servers require rackup daemonize port pid log delay]
            config_orig[opt.to_sym] = value
            nil # rack doesn't have this option

          else
            "--#{opt} #{value}"

        end
      }

      config_orig = { :servers => 1,
                      :port    => 9292,
                      :host    => '0.0.0.0',
                      :log     => 'log/rack_cluster.log',
                      :pid     => 'tmp/pids/rack_cluster.pid',
                      :server  => 'mongrel',
                      :rackup  => 'config.ru' }.merge(config_orig)

      config_orig[:servers].times{ |n|
        config = config_orig.dup

        config[:port] += n
        config[:pid] = RackCluster.pid_path(config[:pid], config[:port])
        config[:log] = RackCluster.log_path(config[:log], config[:port])

        args = [:pid, :log, :user, :group, :chdir].map{ |kind|
          value = config.send(:[], kind)
          value ? "'#{value}'" : 'nil'
        }.join(', ')

        init_script = "AppDeploy::Daemon.daemonize(#{args})"
        ruby_opts   = "-r rubygems -r app-deploy/daemon -e \"#{init_script}\""

        yield( config, ruby_opts, rack_opts + " --port #{config[:port]}" )
      }

    end

    def start config, ruby_opts, rack_opts
      puts "Starting #{config[:server]} on #{config[:host]}:#{config[:port]}..."
      Kernel::system "rackup #{ruby_opts} #{rack_opts} #{config[:rackup]}"
      puts
    end

    def pid_path path, port
      RackCluster.path_with_number(path, port)
    end

    def log_path path, port
      # log should expand path since daemons' working dir is different
      File.expand_path(RackCluster.path_with_number(path, port))
    end

    # extracted from thin
    # Add the server port or number in the filename
    # so each instance get its own file
    def path_with_number path, number
      ext = File.extname(path)
      path.gsub(/#{ext}$/, ".#{number}#{ext}")
    end

  end # of RackCluster
end # of AppDeploy

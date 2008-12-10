
%w[deploy gem git install merb mongrel nginx server thin].each{ |task|
  load "app-deploy/#{task}.rake"
}

module AppDeploy
  module_function
  def clone opts
    user, proj, path = opts[:github_user], opts[:github_project], opts[:git_path]

    if File.exist?(path)
      puts "skip #{proj} because #{path} exists"
    else
      sh "git clone git://github.com/#{user}/#{proj}.git #{path}"
      sh "git --git-dir #{path}/.git gc"
    end
  end

  def install_gem opts
    user, proj, path = opts[:github_user], opts[:github_project], opts[:git_path]
    task = opts[:task_gem]

    cwd = Dir.pwd
    Dir.chdir path
    case task
      when 'bones';
        sh 'rake clobber'
        sh 'rake gem:package'
        sh "gem install --local pkg/#{proj}-*.gem --no-ri --no-rdoc"

      when 'hoe';
        sh 'rake gem'
        sh "gem install --local pkg/#{proj}-*.gem --no-ri --no-rdoc"

      when Proc;
        task.call
    end

  ensure
    Dir.chdir cwd
  end

  def dep; @dep ||= []; end
  def dependency opts = {}
    opts = opts.dup
    opts[:git_path] ||= opts[:github_project]

    dep << opts.freeze
  end

  def gem; @gem ||= []; end
  def dependency_gem opts = {}, &block
    opts = opts.dup
    opts[:git_path] ||= opts[:github_project]

    opts[:task_gem] = block if block_given?
    gem << opts.freeze
  end

  def each
    cwd = Dir.pwd

    (AppDeploy.dep + AppDeploy.gem).each{ |opts|
      puts
      if File.directory?(opts[:git_path])
        Dir.chdir opts[:git_path]
      else
        puts "skipping #{opts[:github_project]}, because it was not found."
        next
      end

      begin
        yield(opts)
      rescue RuntimeError => e
        puts e
      ensure
        Dir.chdir cwd
      end
    }
  end

end

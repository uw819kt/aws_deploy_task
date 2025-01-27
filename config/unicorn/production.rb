 worker_processes  2   # 1.起動するワーカー数を定義
 working_directory "/var/www/cdp_web_web_aws_deploy_task/current"    # 2.Unicornを稼働させるディレクトリを指定
 stderr_path "log/unicorn.stderr.log"    # 3.エラーログの出力先を定義
 stdout_path "log/unicorn.stdout.log"    # 4.標準出力の出力先を定義
 timeout 30    # 5.ワーカープロセスのタイムアウトを秒単位で設定
 listen "/var/www/cdp_web_web_aws_deploy_task/current/tmp/sockets/unicorn.sock"    # 6.UNIXドメインソケットを使ってNginxと連携を想定した設定
 pid '/var/www/cdp_web_web_aws_deploy_task/current/tmp/pids/unicorn.pid'   # 7.Unicornのプロセス（PID）の出力先を定義
 preload_app true    # 8.ワーカープロセス分岐前にアプリケーションをプリロード→trueでダウンタイムなくUnicornの再起動

 before_fork do |server, worker|   # 9.preload_appをtrueに設定する際に、公式で推奨されている設定
   defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
   old_pid = "#{server.config[:pid]}.oldbin"
   if old_pid != server.pid
     begin
       sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
       Process.kill(sig, File.read(old_pid).to_i)
     rescue Errno::ENOENT, Errno::ESRCH
     end
   end
 end

 after_fork do |server, worker|    # 9
   defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
 end
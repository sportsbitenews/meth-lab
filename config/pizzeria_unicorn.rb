worker_processes 2

listen 'unix:/tmp/pizzeria_unicorn.sock', :backlog => 512
#listen 8080, :tcp_nopush => true
timeout 15
preload_app true
pid "./unicorn.pid"
stderr_path "./log/unicorn-err.log"


GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true
check_client_connection false

before_fork do |server, worker|
  # Along with 'verify_active_connections' in after_fork solves unicorn restart errors
  # (disconnect and establish_connection isn't enough since we're using db-charmer gem)
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection_handler.clear_all_connections!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and  ActiveRecord::Base.connection_handler.verify_active_connections!
  defined?(NewRelic::Agent) and NewRelic::Agent.shutdown
  defined?(Gateways::GatewayInitializer) and Gateways::GatewayInitializer.init
  child_pid = server.config[:pid].sub('.pid', ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")

  # Sending a QUIT signal to the old pid AFTER the last worker is up.
  if worker.nr == (server.worker_processes - 1)
    old_pid = "#{server.config[:pid]}.oldbin"
    if File.exists?(old_pid) && server.pid != old_pid
      begin
        old_process_id = File.read(old_pid).to_i
        puts "Sending SIG QUIT to: #{old_process_id}."
        Process.kill("QUIT", old_process_id)
      rescue Errno::ENOENT, Errno::ESRCH
        # someone else did our job for us
      end
    end
  end
end


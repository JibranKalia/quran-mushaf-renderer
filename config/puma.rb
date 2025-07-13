# config/puma.rb

# Puma configuration for production
port ENV.fetch('PORT', 4567)
environment ENV.fetch('RACK_ENV', 'production')

# Number of threads
threads_count = ENV.fetch('PUMA_THREADS', 5).to_i
threads threads_count, threads_count

# Number of workers (processes)
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i

# Preload the application before forking workers
preload_app!

# Allow puma to be restarted by the restart command
plugin :tmp_restart

port ENV.fetch('PORT', 4567)
environment ENV.fetch('RACK_ENV', 'production')

# Number of threads
threads_count = ENV.fetch('PUMA_THREADS', 1).to_i
threads threads_count, threads_count

workers 1

plugin :tmp_restart

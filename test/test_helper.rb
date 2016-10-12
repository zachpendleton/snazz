$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'snazz'
require 'tempfile'

redis = `which redis-server`.chomp
if redis.empty?
  warn "No redis-server executable found"
  exit 1
end
ENV['REDIS_PORT'] ||= ENV.fetch('REDIS_PORT', '9736')
redis_pidfile = Tempfile.new('snazz_redis')
system redis,
       '--daemonize', 'yes',
       '--port', ENV['REDIS_PORT'],
       '--pidfile', redis_pidfile.path

##
# Builds a connection URL string for the test-specific Redis daemon.
def redis_url(host = 'localhost', port = ENV['REDIS_PORT'])
  "redis://#{host}:#{port}"
end

Sidekiq.redis = { url: redis_url }

at_exit do
  pid = File.read(redis_pidfile.path).to_i
  Process.kill('TERM', pid) unless pid.zero?

  redis_pidfile.close
  redis_pidfile.unlink
end

require 'minitest/autorun'

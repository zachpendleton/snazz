module Snazz
  module Concurrent
    class SemaphoreNotAcquiredError < StandardError; end

    class Semaphore
      def initialize(key, connection, max_leases = 1, timeout = 1000)
        @connection = connection
        @key = key
        @max_leases = max_leases
        @timeout = timeout
      end

      def acquired?
        !connection.zscore(key, id).nil?
      end

      def signal
        release
      end

      def wait
        raise SemaphoreNotAcquiredError unless acquire
        yield if block_given?
      ensure
        release if block_given?
      end

      private

      attr_reader :connection, :key, :max_leases

      def acquire
        timeout_threshold = now - @timeout
        acquired_lock = connection.eval(<<-LUA, [key], [max_leases, timeout_threshold, now, id])
local key = KEYS[1]
local max_leases = tonumber(ARGV[1])
local timeout_threshold = tonumber(ARGV[2])
local now = tonumber(ARGV[3])
local id = ARGV[4]

redis.call("zremrangebyscore", key, "-inf", timeout_threshold)
if redis.call("zcount", key, "-inf", "+inf") >= max_leases then
  return 0
end
redis.call("zadd", key, now, id)
return 1
        LUA
        acquired_lock == 1
      end

      def id
        @id ||= File.open("/dev/random") { |f| f.read(5) }.unpack("H*")[0]
      end

      def now
        (Time.now.to_f * 1000).floor
      end

      def release
        connection.zrem(key, id)
      end
    end
  end
end

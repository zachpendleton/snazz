require "test_helper"

module Snazz
  module Middleware
    class ThrottlingMiddlewareTest < Minitest::Test
      def setup
        @connection = Redis.new(url: "redis://localhost:6379")
        @subject = ThrottlingMiddleware.new
        @worker = Snazz::Worker::ThrottledWorker.new
        @queue = "default"
        @connection.flushdb
      end

      def test_it_skips_workers_that_arent_throttled
        called = false

        @subject.call("other worker", {}, @queue) do
          called = true
        end

        assert called
      end

      def test_it_acquires_a_lock_when_called_with_a_throttled_worker
        @subject.call(@worker, {}, @queue) do
          assert_equal 1, @connection.zcount(@worker.key, "-inf", "+inf")
        end
      end

      def test_it_reschedules_workers_when_a_lock_cannot_be_held
        @subject.call(@worker, {}, @queue) do
          @subject.call(@worker, {}, @queue) {}
        end

        assert_equal 1, @connection.llen("queue:#{@queue}")
      end
    end
  end
end

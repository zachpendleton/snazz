require "test_helper"

module Snazz
  module Middleware
    class ThrottlingMiddlewareTest < Minitest::Test
      class FakeWorker
        include Snazz::Worker::ThrottledWorker
      end

      def setup
        @connection = Redis.new(url: redis_url)
        @subject = ThrottlingMiddleware.new
        @worker = FakeWorker.new
        @queue = "default"
        @throttle_key = "throttled"
        @connection.flushdb
      end

      def a_job
        {"args" => [{"key" => @throttle_key}]}
      end

      def test_it_skips_workers_that_arent_throttled
        called = false

        @subject.call("other worker", a_job, @queue) do
          called = true
        end

        assert called
      end

      def test_it_acquires_a_lock_when_called_with_a_throttled_worker
        @subject.call(@worker, a_job, @queue) do
          assert_equal 1, @connection.zcount(@throttle_key, "-inf", "+inf")
        end
      end

      def test_it_reschedules_workers_when_a_lock_cannot_be_held
        @subject.call(@worker, a_job, @queue) do
          @subject.call(@worker, a_job, @queue) {}
        end

        assert_equal 1, @connection.llen("queue:#{@queue}")
      end

      def test_it_uses_key_specified_in_job_options
        job = {"args" => [{"key" => "override"}]}
        @subject.call(@worker, job, @queue) do
          assert_equal 1, @connection.zcount("override", "-inf", "+inf")
          assert_equal 0, @connection.zcount(@worker.key, "-inf", "+inf")
        end
      end
    end
  end
end

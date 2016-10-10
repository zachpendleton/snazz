require "test_helper"
require "snazz/worker/throttled_worker"

module Snazz
  module Worker
    class ThrottledWorkerTest < Minitest::Test
      def setup
        @subject = Snazz::Worker::ThrottledWorker.new
      end

      def test_it_has_a_key
        assert_equal Snazz::Worker::ThrottledWorker::DEFAULT_KEY, @subject.key
      end

      def test_it_has_a_max_leases_count
        assert_equal Snazz::Worker::ThrottledWorker::DEFAULT_LEASE_COUNT, @subject.max_leases
      end

      def test_it_has_a_timeout
        assert_equal Snazz::Worker::ThrottledWorker::DEFAULT_TIMEOUT, @subject.timeout
      end
    end
  end
end

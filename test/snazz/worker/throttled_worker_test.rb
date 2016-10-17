require "test_helper"
require "snazz/worker/throttled_worker"

module Snazz
  module Worker
    class ThrottledWorkerTest < Minitest::Test
      class FakeWorker
        include Snazz::Worker::ThrottledWorker
      end

      def setup
        @subject = FakeWorker.new
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

      def test_perform_async_sets_options
        worker_class = Class.new do
          # Simulate including Sidekiq::Worker
          extend(Module.new do
            def called_with
              @called_with
            end

            def perform_async(*args)
              @called_with = args
            end
          end)

          include Snazz::Worker::ThrottledWorker
        end
        worker_class.perform_async(key: "override")
        assert_equal [{"key" => "override"}],
                     worker_class.called_with
      end
    end
  end
end

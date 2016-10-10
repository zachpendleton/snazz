require "test_helper"
require "redis"
require "snazz/concurrent/semaphore"

module Snazz
  module Concurrent
    class SemaphoreTest < Minitest::Test
      KEY = "key"
      MAX_LEASES = 1
      TIMEOUT = 100

      def setup
        @connection = Redis.new(url: "redis://localhost:6379")
        @subject = Semaphore.new(KEY, @connection, 1, 500)
        @connection.flushdb
      end

      def test_it_acquires_a_lock
        lock_acquired = false

        @subject.wait do |conn|
          lock_acquired = true
        end

        assert lock_acquired
      end

      def test_it_raises_when_a_lock_cannot_be_acquired
        @other_subject = create_semaphore

        assert_raises SemaphoreNotAcquiredError do
          @subject.wait do |conn|
            @other_subject.wait { |conn| }
          end
        end
      end

      def test_it_releases_the_lock_if_the_timeout_has_passed
        @other_subject = create_semaphore

        Thread.new do
          @subject.wait do |conn|
            sleep (TIMEOUT * 2) / 1000.0
          end
        end
        sleep (TIMEOUT * 1.5) / 1000.0
        acquired_lock = false
        @other_subject.wait do |conn|
          acquired_lock = true
        end

        assert acquired_lock
      end

      def test_it_releases_the_lock_after_block_executes
        @subject.wait { |conn| }
        assert !@subject.acquired?
      end

      def test_it_holds_the_lock_if_a_block_isnt_given
        @subject.wait
        assert @subject.acquired?
      end

      private

      def create_semaphore(leases = MAX_LEASES, timeout = TIMEOUT)
        Semaphore.new(KEY, @connection, leases, timeout)
      end
    end
  end
end

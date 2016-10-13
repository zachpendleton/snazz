# frozen_string_literal: true
require "json"
require "sidekiq"
require "snazz/concurrent/semaphore"
require "snazz/worker/throttled_worker"

module Snazz
  module Middleware
    class ThrottlingMiddleware
      def call(worker, job, queue, &block)
        return yield unless worker.is_a?(Snazz::Worker::ThrottledWorker)
        Sidekiq.redis do |connection|
          begin
            options = job["args".freeze].pop
            key = options.fetch("key".freeze)
            semaphore = Snazz::Concurrent::Semaphore.new(key,
                                                         connection,
                                                         worker.max_leases,
                                                         worker.timeout)
            semaphore.wait(&block)
          rescue KeyError
            Sidekiq.logger.error "No semaphore key provided".freeze
          rescue Snazz::Concurrent::SemaphoreNotAcquiredError
            connection.lpush("queue:#{queue}", job.to_json)
          end
        end
      end
    end
  end
end

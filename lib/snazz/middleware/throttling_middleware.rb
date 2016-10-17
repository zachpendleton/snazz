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
            semaphore = Snazz::Concurrent::Semaphore.new(worker.key,
                                                         connection,
                                                         worker.max_leases,
                                                         worker.timeout)
            semaphore.wait(&block)
          rescue Snazz::Concurrent::SemaphoreNotAcquiredError
            connection.lpush("queue:#{queue}", job.to_json)
          end
        end
      end
    end
  end
end

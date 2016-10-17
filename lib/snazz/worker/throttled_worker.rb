module Snazz
  module Worker
    module ThrottledWorker
      DEFAULT_KEY = "snazz:throttled".freeze

      DEFAULT_LEASE_COUNT = 1

      DEFAULT_TIMEOUT = 1_000

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Overrides the basic Sidekiq::Worker version to append an options hash
        # with a key string that will provide the throttling scope for the job.
        def perform_async(*args, key: nil)
          if key
            args.push("key".freeze => key)
          else
            args.push({})
          end
          super(*args)
        end
      end

      def key
        DEFAULT_KEY
      end

      def max_leases
        DEFAULT_LEASE_COUNT
      end

      def timeout
        DEFAULT_TIMEOUT
      end
    end
  end
end

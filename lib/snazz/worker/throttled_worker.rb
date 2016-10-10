module Snazz
  module Worker
    class ThrottledWorker
      DEFAULT_KEY = "snazz:throttled"

      DEFAULT_LEASE_COUNT = 1

      DEFAULT_TIMEOUT = 1_000

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

module Snazz
  module Middleware
    class TimingMiddleware
      def call(worker, job, queue)
        yield
      end
    end
  end
end

module Snazz
  module Middleware
    class SequentialMiddleware
      def call(worker, job, queue)
        yield
      end
    end
  end
end

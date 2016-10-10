module Snazz
  module Middleware
    class SingletonMiddleware
      def call(worker, job, queue)
        yield
      end
    end
  end
end

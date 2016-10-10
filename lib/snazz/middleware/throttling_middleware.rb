module Snazz
  module Middleware
    class ThrottlingMiddleware
      def call(worker, job, queue)
        yield
      end
    end
  end
end

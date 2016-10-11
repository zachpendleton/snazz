require "test_helper"
require "minitest/mock"

module Snazz
  module Middleware
    class TimingMiddlewareTest < Minitest::Test
      def test_that_it_times_a_successful_request
        socket = MiniTest::Mock.new
        socket.expect(:send, nil, ["jobs.Object:10000|ms", 0, "localhost", 8125])
        UDPSocket.stub(:new, socket) do
          now = Time.now
          start, finish = now - 10.0, now
          clock = [start, finish]
          def clock.now; shift end

          middleware = TimingMiddleware.new(clock: clock)
          middleware.call(Object.new, {}, "default") do
            # no-op
          end
        end

        socket.verify
      end
    end
  end
end

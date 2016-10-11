require "socket"

module Snazz
  module Middleware
    class TimingMiddleware
      def initialize(host: "localhost", port: 8125,
                     prefix: "jobs".freeze,
                     logger: Sidekiq.logger,
                     clock: Time)
        @host, @port = host, port
        @prefix = prefix
        @logger = logger
        @clock = clock
      end

      def call(worker, job, queue)
        time(worker, job, queue) do
          yield
        end
      end

      private

      def time(*args)
        start = @clock.now
        yield
        send_timing(*args, @clock.now - start)
      end

      def send_timing(worker, _, _, seconds)
        message = "%{name}:%{quantity}|%{unit}".freeze % {
          name: "%s.%s".freeze % [@prefix, worker.class.name],
          quantity: (seconds.to_f * 1000).to_i,
          unit: "ms".freeze,
        }
        @logger.debug { "snazz.timing: #{message}" }
        socket.send(message, 0, @host, @port)
      rescue => ex
        @logger.warn "snazz.timing: unable to send message: [#{ex.class.name}] #{ex}"
      end

      def socket
        Thread.current[:snazz_timing_socket] ||= UDPSocket.new
      end
    end
  end
end

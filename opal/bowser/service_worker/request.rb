module Bowser
  module ServiceWorker
    class Request
      def initialize url, options={}
        @url = url
        @options = options
        @native = `new Request(url, #{options.to_n})`
      end

      def self.from_native native
        request = allocate
        request.instance_exec { @native = native }
        request
      end

      def inspect
        "#<Request:0x#{object_id.to_s(16)} @url=#{url}>"
      end

      def url
        @url || `#@native.url`
      end

      def to_n
        @native
      end
    end
  end
end

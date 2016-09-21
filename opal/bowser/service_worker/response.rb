module Bowser
  module ServiceWorker
    class Response
      def self.from_native native
        new(native) if `#{native} != null`
      end

      def initialize native
        @native = native
      end

      def json
        `#@native.json()`
      end

      def text
        `#@native.text()`
      end

      def to_n
        @native
      end
    end
  end
end

module Bowser
  module HTTP
    # Data to be attached to a form or sent in with a Bowser::HTTP::Request
    class FormData
      # param attributes [Hash, nil] the attributes to attach
      def initialize(attributes={})
        @native = `new FormData()`

        attributes.to_h.each do |key, value|
          append key, value
        end
      end

      # @param key [String] the name of the attribute
      # @param value [String] the value of the attribute
      def append key, value
        data = if `!!value.native`
                 `value.native`
               else
                 value
               end

        `#@native.append(key, data)`
      end
    end
  end
end

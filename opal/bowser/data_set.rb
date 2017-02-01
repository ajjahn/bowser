module Bowser
  class DataSet
    def initialize(native)
      @native = native
    end

    def [](attr)
      `#@native[#{camel_case(attr)}]`
    end

    def []=(attr, value)
      `#@native[#{camel_case(attr)}] = #{value}`
    end

    def method_missing(name, *args, &block)
      return self[name] = args[0] if name.end_with? '='
      self[name]
    end

    def to_n
      @native
    end

    def camel_case(str)
      str.gsub(/_\w/) { |match| match[1].upcase }.sub(/=$/, '')
    end
  end
end

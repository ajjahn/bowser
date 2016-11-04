module Bowser
  class URL
    attr_reader :scheme, :username, :password, :host, :port, :path, :search, :hash

    PORTS = {
      http: 80,
      https: 443,
    }

    def initialize(url)
      @url = url
      # scheme://conn_data/path?query#hash
      match = url.match(%r[(\w+)://([^/]+)([^\?]+)(\?[^\#]+)?(\#.*)?])

      _, @scheme, connection_data, @path, @search, @hash = match.to_a

      connection_data = connection_data.split(/@/)
      if connection_data.size > 1
        @username, @password = connection_data.first.split(/:/)
      end
      @host, @port = connection_data.last.split(/:/)

      @port = @port.to_i
    end

    def query
      search[1..-1].split('&').map { |chunk| chunk.split('=') }.each_with_object({}) { |(key, value), hash|
        key = key.to_sym
        hash[key] = if hash[key]
                      Array(hash[key]).push(value)
                    else
                      value
                    end
      }
    end
  end
end

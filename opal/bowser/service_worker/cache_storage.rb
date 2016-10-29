require 'bowser/service_worker/response'
require 'bowser/service_worker/promise'

module Bowser
  module ServiceWorker
    class CacheStorage
      def initialize
        @native = `caches`
      end

      def match request, options={}
        Promise.new.tap do |promise|
          resolve = proc do |value|
            promise.resolve(value && Response.from_native(value))
          end
          reject = proc do |error|
            promise.reject(error)
          end

          %x{
          #@native.match(#{request.to_n}, #{options.to_n})
            .then(resolve).catch(reject);
          }
        end
      end

      def has name
        Promise.new.tap do |promise|
          %x{
          #@native.has(name)
            .then(#{proc { |value| promise.resolve value }})
            .catch(#{proc { |error| promise.reject error }});
          }
        end
      end

      def open cache
        promise = Promise.new
        %x{
        #@native.open(cache)
          .then(#{proc { |native| promise.resolve Cache.new(native) }})
          .catch(#{proc { |error| puts "failed: #{error}" }})
        }

        promise
      end

      class Cache
        def initialize native
          @native = native
        end

        def add_all requests
          promise = Promise.new

          %x{
          #@native.addAll(#{requests.map(&:to_n)})
            .then(#{proc { promise.resolve nil }})
            .catch(#{proc { |error| promise.reject error; puts "BOOOO! #{error}" }});
          }

          promise
        end

        def put request, response
          `#@native.put(#{request.to_n}, #{response.to_n})`
        end

        def to_n
          @native
        end
      end
    end
  end
end

require 'opal'
require 'native'
require 'bowser/service_worker/extendable_event'
require 'bowser/service_worker/fetch_event'
require 'bowser/service_worker/cache_storage'
require 'bowser/service_worker/request'
require 'bowser/service_worker/response'
require 'bowser/service_worker/promise'

# Opal uses `self` internally, but we can use `this` to get the worker reference
%x{ var worker = this; }

module Bowser
  module ServiceWorker
    class Context
      def initialize native
        @native = native
      end

      def on event_name, &block
        event_type = EVENT_TYPES.fetch(event_name) { ExtendableEvent }
        handler = proc { |event| block.call(event_type.new(event)) }

        %x{#@native.addEventListener(event_name, handler);}

        self
      end

      def to_n
        @native
      end

      def caches
        @caches ||= CacheStorage.new
      end

      def fetch url
        Promise.new.tap do |promise|
          %x{
            fetch(#{url.to_n})
              .then(#{proc { |response|
                promise.resolve Response.from_native(response)
              }})
              .catch(#{proc { |error| promise.reject error }})
          }
        end
      end

      EVENT_TYPES = {
        fetch: FetchEvent,
      }
    end
  end
end

def self.worker
  Bowser::ServiceWorker::Context.new(`worker`)
end

def self.method_missing(*args, &block)
  worker.send(*args, &block)
end

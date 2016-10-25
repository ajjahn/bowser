module Bowser
  class Promise
    attr_reader :value, :reason

    def self.resolve value=nil
      new { |resolve| resolve.call value }
    end

    def self.reject reason=nil
      new { |_, reject| reject.call reason }
    end

    def initialize
      @on_resolve = []
      @on_reject = []
      @children = []

      if block_given?
        yield method(:resolve), method(:reject), self
      end
    end

    def then
      Promise.new do |resolve, _, p|
        @on_resolve << proc { |value| resolve[yield value] } if block_given?
        @children << p
      end
    end

    def catch(&block)
      Promise.new do |_, reject, p|
        @on_reject << block if block_given?
        @children << p
      end
    end
    alias fail catch

    def resolve value=nil
      return unless pending?
      if value.equal? self
        reject TypeError.new('you cannot resolve a promise with itself')
      end
      if self.class === value
        value.then  { |v| resolve v }
        value.catch { |r| reject r }

        return
      end

      @on_resolve.each do |block|
        block.call value
      end
      @children.each do |child|
        child.resolve value
      end

      @value = value
    rescue => e
      reject e
    end

    def reject reason
      return unless pending?
      if value.equal? self
        reject TypeError.new('you cannot resolve a promise with itself')
      end
      if self.class === value
        value.catch { |v| reject v }
        return
      end

      @on_reject.each do |block|
        block.call reason
      end
      @children.each do |child|
        child.reject reason
      end

      @reason = reason
    end

    def resolved?
      !!defined? @value
    end

    def rejected?
      !!defined? @reason
    end

    def pending?
      !(resolved? || rejected?)
    end
  end
end

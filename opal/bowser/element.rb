require 'bowser/event_target'
require 'bowser/file_list'

module Bowser
  # Wrap a native DOM element
  class Element
    include EventTarget

    # @param native [JS] The native DOM element to wrap
    def initialize native
      @native = native
    end

    # Replace all child elements with the given element
    #
    # @param element [Bowser::Element] The Bowser element with which to replace
    #   this element's contents
    def inner_dom= element
      clear
      append element
    end

    # The contents of this element as an HTML string
    #
    # @return [String] the HTML representation of this element's contents
    def inner_html
      `#@native.innerHTML`
    end

    # Use the supplied HTML string to replace this element's contents
    #
    # @param html [String] the HTML with which to replace this elements contents
    def inner_html= html
      `#@native.innerHTML = html`
    end

    # This element's direct child elements
    #
    # @return [Array<Bowser::Element>] list of this element's children
    def children
      elements = []

      %x{
        var children = #@native.children;
        for(var i = 0; i < children.length; i++) {
          elements[i] = #{Element.new(`children[i]`)};
        }
      }

      elements
    end

    # Determine whether this element has any contents
    #
    # @return [Boolean] true if the element has no children, false otherwise
    def empty?
      `#@native.children.length === 0`
    end

    # Remove all contents from this element. After this call, `empty?` will
    # return `true`.
    #
    # @return [Bowser::Element] self
    def clear
      if %w(input textarea).include? type
        `#@native.value = null`
      else
        children.each do |child|
          remove_child child
        end
      end

      self
    end

    # Remove the specified child element
    #
    # @param child [Bowser::Element] the child element to remove
    def remove_child child
      `#@native.removeChild(child.native ? child.native : child)`
    end

    # This element's type. For example: "div", "span", "p"
    #
    # @return [String] the HTML tag name for this element
    def type
      `#@native.nodeName`.downcase
    end

    # Append the specified element as a child element
    #
    # @param element [Bowser::Element, JS] the element to insert
    def append element
      `#@native.appendChild(element.native ? element.native : element)`
      self
    end

    # Methods for <input /> elements

    # A checkbox's checked status
    #
    # @return [Boolean] true if the checkbox is checked, false otherwise
    def checked?
      `!!#@native.checked`
    end

    # Get the currently selected file for this input. This is only useful for
    # file inputs without the `multiple` property set.
    #
    # @return [Bowser::File] the file selected by the user
    def file
      files.first
    end

    # Get the currently selected files for this input. This is only useful for
    # file inputs with the `multiple` property set.
    #
    # @return [Bowser::FileList] the currently selected files for this input
    def files
      FileList.new(`#@native.files`)
    end

    # Fall back to native properties. If the message sent to this element is not
    # recognized, it checks to see if it is a property of the native element. It
    # also checks for variations of the message name, such as:
    #
    #   :supported? => [:supported, :isSupported]
    #
    # If a property with the specified message name is found and it is a
    # function, that function is invoked with `args`. Otherwise, the property
    # is returned as is.
    def method_missing message, *args, &block
      camel_cased_message = message
        .gsub(/_\w/) { |match| match[1].upcase }
        .sub(/=$/, '')

      # translate setting a property
      if message.end_with? '='
        return `#@native[camel_cased_message] = args[0]`
      end

      # translate `supported?` to `supported` or `isSupported`
      if message.end_with? '?'
        camel_cased_message = camel_cased_message.chop
        property_type = `typeof(#@native[camel_cased_message])`
        if property_type == 'undefined'
          camel_cased_message = "is#{camel_cased_message[0].upcase}#{camel_cased_message[1..-1]}"
        end
      end

      # If the native element doesn't have this property, bubble it up
      super if `typeof(#@native[camel_cased_message]) === 'undefined'`

      property = `#@native[camel_cased_message]`

      if `property === false`
        return false
      else
        property = `property || nil`
      end

      # If it's a method, call it. Otherwise, return it.
      if `typeof(property) === 'function'`
        `property.apply(#@native, args)`
      else
        property
      end
    end

    # The native representation of this element.
    #
    # @return [JS] the native element wrapped by this object.
    def to_n
      @native
    end
  end
end

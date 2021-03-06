require 'sitehub/equality'
require 'sitehub/cookie/attribute'
require 'sitehub/cookie/flag'
require 'sitehub/constants'
class SiteHub
  class Cookie
    attr_reader :attributes_and_flags, :name_attribute
    include Constants, Equality

    FIRST = 0

    def initialize(cookie_string)
      @attributes_and_flags = cookie_string.split(SEMICOLON).map do |entry|
        if entry.include?(EQUALS_SIGN)
          Cookie::Attribute.new(*entry.split(EQUALS_SIGN))
        else
          Cookie::Flag.new(entry)
        end
      end

      name_attribute = @attributes_and_flags.delete_at(FIRST)
      @name_attribute = Cookie::Attribute.new(name_attribute.name.to_s, name_attribute.value)
    end

    def name
      name_attribute.name
    end

    def value
      name_attribute.value
    end

    def find(name)
      attributes_and_flags.find { |entry| entry.name == name }
    end

    def to_s
      [name_attribute].concat(attributes_and_flags).join(SEMICOLON_WITH_SPACE)
    end
  end
end

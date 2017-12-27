# frozen_string_literal: true

module FtlFont
  module Binary
    # A utility class that allows BitStruct to display
    # a Unicode codepoint as an actual UTF-8 character.
    # It abuses Ruby's duck typing to make this class
    # look like a format string that BitStruct wants.
    class Utf8CodeFormatter
      class << self
        def call(str)
          str.to_i.chr(Encoding::UTF_8)
        end
        alias % call
      end
    end
  end
end

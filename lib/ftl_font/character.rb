require "bit-struct"
require_relative "utf8_code_formatter"

class FtlFont
  class Character < BitStruct
    unsigned :character,    32, "Character", format: Utf8CodeFormatter
    unsigned :x,            16, "Left"
    unsigned :y,            16, "Top"
    unsigned :w,            8,  "Width"
    unsigned :h,            8,  "Height"
    signed :baseline,       8,  "Baseline location"
    signed :before_spacing, 16 # not sure yet
    signed :after_spacing,  16 # not sure yet
    octets :unknown1,       8
    # 128 bits = 16 bytes total

    # The #character field is actually a number
    # of the UTF-8 character this record is about.
    # These accessors allow you to work with it
    # as single-char UTF-8 string. Neato.
    def utf8_character
      character.chr(Encoding::UTF_8)
    end

    def utf8_character=(c)
      self.character = c.ord
    end
  end
end

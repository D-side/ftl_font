# frozen_string_literal: true

require "bit-struct"
require_relative "utf8_code_formatter"

module FtlFont
  module Binary
    # A single binary entry of a character table. It contains data about the
    # character itself as well as its location in the font's texture
    class Character < BitStruct
      unsigned :character,  32, "Character", format: Utf8CodeFormatter
      unsigned :left,       16, "Left"
      unsigned :top,        16, "Top"
      unsigned :width,      8,  "Width"
      unsigned :height,     8,  "Height"
      signed :baseline,     8,  "Baseline location"
      signed :before,       16, "Spacing before" # not sure yet
      signed :after,        16, "Spacing after" # not sure yet
      octets :unknown1,     8
      # 128 bits = 16 bytes total
      alias w width
      alias h height
      alias b baseline
      alias x left
      alias y top

      # Some characters occupy an area of zero pixels, as surprising as this
      # may sound. ChunkyPNG is fine with exporting PNGs like this one, but
      # it isn't okay with importing them back. Use this method to circumvent
      # this.
      def empty?
        (w * h).zero?
      end

      # Returns an image of this particular symbol on the given PNG texture.
      # Or nil, if it's not possible.
      def image_from(png_texture)
        png_texture.crop(x, y, w, h) unless empty?
      end

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
end

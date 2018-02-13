# frozen_string_literal: true

require "bit-struct"
require_relative "character"

module FtlFont
  class Binary
    # A section of the file labeled FONT. Contains data about the font
    # as a whole and a table of characters.
    class Font < BitStruct
      unsigned :fixed, 32
      octets :unknown1, 64
      unsigned :character_count, 16
      unsigned :character_length, 16 # not sure yet
      unsigned :section_size, 32 # 16-byte offset
      octets :unknown2, 8
      unsigned :tex_height, 16 # ?!
      octets :unknown3, 8

      # Total size of "useful data", in bytes.
      def total_payload_size
        length + 16 * character_count
      end

      # Returns the number of bytes required to offset total section size
      # to a multiple of 64, as in the original files.
      def padding_size
        -total_payload_size % 64
      end

      # A string of padding symbols to be concatenated with the result
      def padding
        "\0" * padding_size
      end

      # Complete size of the section
      def total_padded_size
        total_payload_size + padding_size
      end

      def inspect
        "#<#{self.class} #{to_h.inspect}>"
      end
    end
  end
end

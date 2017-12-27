# frozen_string_literal: true

require "bit-struct"
require_relative "character"

module FtlFont
  module Binary
    # A section of the file labeled FONT. Contains data about the font
    # as a whole and a table of characters.
    class FontSection < BitStruct
      unsigned :fixed, 32
      octets :unknown1, 64
      unsigned :character_count, 16
      unsigned :character_length, 16 # not sure yet
      unsigned :section_size, 32 # 16-byte offset
      octets :unknown2, 32
      # 192 bits = 24 bytes total
      # character_count entries of Character right after that
      rest :character_table_raw

      def characters
        @character_table ||= CharacterTable.new(self, character_count)
      end

      def padding_length
        character_table_raw.length - character_count * 16
      end

      # Returns a section padded to have size in bytes a multiple of 64. You
      # only typically need to do this when writing down this section.
      def export
        dup.tap do |exported|
          pad_length = (64 - size % 64) % 64
          exported.section_size += pad_length
          exported << ("\0" * pad_length)
        end
      end

      def inspect
        summary = {
          characters: character_count,
          section_size: section_size,
          character_length: character_length,
          padding_length: padding_length
        }
        "#<#{self.class} #{summary.inspect}>"
      end

      # A wrapper for working with a character table as if it were a
      # zero-indexed array of Character instances.
      CharacterTable = Struct.new(:font_section, :length) do
        alias_method :size, :length

        include Enumerable
        def each
          return enum_for(:each) unless block_given?
          (0...length).each { |i| yield(self[i]) }
        end

        def [](index)
          Character.new(raw[index * 16, 16])
        end

        def []=(index, char)
          raise ArgumentError unless char.is_a?(Character)
          table = raw
          table[index * 16, 16] = char.to_s
          font_section.character_table_raw = table
        end

        private

        def raw
          font_section.character_table_raw
        end
      end
    end
  end
end

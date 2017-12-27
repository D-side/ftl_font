# frozen_string_literal: true

require "json"

require_relative "font_section"
require_relative "tex_section"

module FtlFont
  module Binary
    File = Struct.new(:font, :tex, :name) do
      INDEXES_LIST_FILE = "indexes.json"
      DEFAULT_INDEX = "source.json"
      DEFAULT_INDEXES = JSON.pretty_generate([DEFAULT_INDEX]).freeze

      def self.open(path)
        name = ::File.basename(path, ".*")
        bytes = ::File.read(path, mode: "rb", encoding: "binary")
        from_binstring(bytes, name)
      end

      def self.from_binstring(bytes, name = nil)
        font_section_size = bytes[16, 4].bytes.reduce { |n, d| n * 256 + d }
        font = FontSection.new(bytes[0, font_section_size])
        tex = TexSection.new(bytes[font_section_size..-1])
        new(font, tex, name)
      end

      def dismantle_into(directory)
        texture = tex.png
        data = font.characters.map do |c|
          filename = "#{c.character}.png"
          image = c.image_from(texture)
          image&.save(::File.join(directory, filename))
          {
            character: c.utf8_character,
            image: (filename if image),
            w: c.w,
            h: c.h,
            before: c.before,
            after: c.after
          }
        end
        ::File.write(
          ::File.join(directory, DEFAULT_INDEX),
          JSON.pretty_generate(data)
        )
        ::File.write(
          ::File.join(directory, INDEXES_LIST_FILE),
          DEFAULT_INDEXES
        )
      end

      def inspect
        summary = {
          name: name,
          font: font,
          tex: tex
        }
        "#<#{self.class} #{summary.inspect}>"
      end
    end
  end
end

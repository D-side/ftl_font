# frozen_string_literal: true

require "json"

require_relative "binary/font"
require_relative "binary/character"
require_relative "binary/tex"

module FtlFont
  # A container for binary representation of a font file
  BinaryWrapper = Struct.new(:font, :chars, :tex, :tag) do
    # Constructs an instance of the
    def self.load(filename)
      bytes = File.read(filename, mode: "rb", encoding: "binary")
      font = Binary::Font.new(bytes[0, 24])
      new(
        font,
        (0...font.character_count).map { |i| Binary::Character.new(bytes[24 + 16 * i, 16]) },
        Binary::Tex.new(bytes[font.section_size..-1]),
        File.basename(filename, ".font")
      )
    end

    # Sanity check to be done on unmodified structs to ensure conversions do not corrupt the data
    def identical_to_file?(filename)
      dump == File.read(filename, mode: "rb", encoding: "binary")
    end

    def save(filename)
      File.write(filename, dump, encoding: "binary", mode: "wb")
    end

    # Dumps the structs as a single binary string for writing into a file.
    def dump
      font + chars.join + font.padding + tex
    end

    # Dismantles the font in editable format for
    def dismantle_into(directory)
      texture = tex.png
      data = chars.reject(&:empty?).map do |c|
        filename = "#{c.character}.png"
        c.image_from(texture).save(File.join(directory, filename))
        {
          character: c.utf8_character,
          baseline: c.baseline,
          image: filename,
          before: c.before,
          after: c.after
        }
      end
      File.write(File.join(directory, "index.json"), JSON.pretty_generate(data))
    end
  end
end

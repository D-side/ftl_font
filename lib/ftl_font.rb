require "chunky_png"
require "bit-struct"
require "json"

require "ftl_font/character"
require "ftl_font/font_section"
require "ftl_font/tex_section"

# Represents a font in a structured way
# Needs splitting into its binary and structured
class FtlFont
  attr_accessor :bytes, :font_section, :tex_section, :characters

  class << self
    private :new
  end

  # Builds an instance of FtlFont class with data read from the file
  # at a given path.
  def self.open(filename)
    new.tap do |f|
      f.bytes = File.read(filename, encoding: "binary")
      f.font_section = FontSection.new(f.bytes[0, 24])
      f.characters = (0..f.font_section.character_count - 1).map do |i|
        Character.new(f.bytes[24 + 16 * i, 16])
      end
      f.tex_section = TexSection.new(f.bytes[f.font_section.section_size..-1])
    end
  end

  # Dismantles the contents of this font into the specified folder.
  # Overwrites any files in there that it sees fit.
  def dismantle_into(path)
    save_manifest(path)
    save_character_pngs(path)
    true
  end

  private

  def texture
    tex_section.png
  end

  def save_character_pngs(path)
    characters.each do |c|
      # Spaces of h 0 have been encountered that ChunkyPNG
      # tolerates when saving, but blows up when loading results
      next if c.w == 0 || c.h == 0
      texture.crop(c.x, c.y, c.w, c.h)
             .save(File.join(path, c.utf8_character.ord.to_s << ".png"))
    end
    true
  end

  def save_manifest(path)
    data = characters.map do |c|
      image = if c.w != 0 && c.h != 0
        "#{c.character}.png"
      else
        # The PNG would be invalid, but some data
        # has to be preserved nonetheless
        { w: c.w, h: c.h }
      end
      {
        character: c.utf8_character,
        baseline: c.baseline,
        image: image
      }
    end
    File.write(
      File.join(path, "index.json"),
      JSON.pretty_generate(data)
    )
    true
  end
end

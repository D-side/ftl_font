#!/usr/bin/env ruby

# frozen_string_literal: true

# Necessary for incremental output in tools like atom-build
STDOUT.sync = true

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require "ftl_font"

Dir["font_templates/*.json"].each do |template_file|
  template = JSON.parse(File.read(template_file, encoding: "utf-8"))
  binwrap = FtlFont::BinaryWrapper.load(File.join("fonts", template["source"]))
  from_png = binwrap.tex.png
  character_index = {}

  original_char = binwrap.chars.first
  binwrap.chars.each do |c|
    character_index[c.utf8_character] = c
    c.temp_image = c.image_from(from_png)
  end

  template["additions"].each do |additions_folder|
    additions_path = File.join("additions", additions_folder)
    additions_index =
      JSON.parse(
        File.read(
          File.join(additions_path, "index.json"),
          encoding: "utf-8"
        )
      )
    additions_index.each do |added_char_data|
      # FIXME: assumes additions cannot have empty characters
      img = ChunkyPNG::Image.from_file(File.join(additions_path, added_char_data["image"]))
      character_index[added_char_data["character"]] = FtlFont::Binary::Character.new(
        character: added_char_data["character"].ord,
        width: img.width,
        height: img.height,
        baseline: added_char_data["baseline"],
        before: added_char_data["before"],
        after: added_char_data["after"],
        unknown1: original_char.unknown1
      ).tap { |char| char.temp_image = img }
    end
  end

  binwrap.chars = character_index.values

  texture_builder = FtlFont::Builder::Texture.new
  binwrap.chars.each do |char|
    recorner = proc do |x, y|
      char.left = x
      char.top = y
    end
    if char.temp_image
      texture_builder.append_image!(char.temp_image, char.utf8_character, &recorner)
    else
      texture_builder.reserve_space!(char.w, char.h, char.utf8_character, &recorner)
    end
  end

  binwrap.tex.png = texture_builder.texture
  binwrap.font.character_count = binwrap.chars.size
  binwrap.font.section_size = binwrap.font.total_padded_size
  binwrap.font.tex_height = binwrap.tex.height

  font_name = File.basename(template_file, ".json")
  binwrap.save(File.join("assembled", "#{font_name}.font"))
end

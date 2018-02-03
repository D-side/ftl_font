#!/usr/bin/env ruby

# frozen_string_literal: true

# Necessary for incremental output in tools like atom-build
STDOUT.sync = true

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require "ftl_font"

Dir["font_templates/*.json"]
  .tap { |fns| puts "--- #{fns.size} files found" }
  .each do |filename|
  basename = File.basename(filename, ".*")
  path = File.join("assembled", basename)
  if Dir.exist?(path)
    puts "| | [#{filename}]\n    skipped: folder at [#{path}] already exists"
    next
  end
  print "|*| [#{filename}] => [#{path}]\n    working... "
  Dir.mkdir(path)
  folders = JSON.parse(File.read(filename, encoding: Encoding::UTF_8))
  cl = FtlFont::Builder::CharacterList.new
  folders.each { |f| cl.append_folder!(f) }
  tex = FtlFont::Builder::Texture.new
  cl.list.to_a.
    # sort_by { |d| d[1]["h"] }.reverse!. # for more optimal layout
    each do |(c, data)|
    if data["png"]
      tex.append_image!(data["png"], c)
    else
      tex.reserve_space!(data["w"], data["h"], data["character"])
    end
  end
  tex.export(path)
  puts "done!"
end

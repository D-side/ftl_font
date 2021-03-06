#!/usr/bin/env ruby

# frozen_string_literal: true

# Necessary for incremental output in tools like atom-build
STDOUT.sync = true

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require "ftl_font"

Dir["fonts/*.font"]
  .tap { |fns| puts "--- #{fns.size} files found" }
  .each do |filename|
  basename = File.basename(filename, ".*")
  path = File.join("additions", "#{basename}.original")
  if Dir.exist?(path)
    puts "| | [#{filename}]\n    skipped: folder at [#{path}] already exists"
    next
  end
  print "|*| [#{filename}] => [#{path}]\n    working... "
  Dir.mkdir(path)
  FtlFont::BinaryWrapper.load(filename).dismantle_into(path)
  puts "done!"
end

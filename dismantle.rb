#!/usr/bin/env ruby

# frozen_string_literal: true

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require "ftl_font"

Dir["fonts/*.font"]
  .tap { |fns| puts "--- #{fns.size} files found" }
  .each do |filename|
  basename = File.basename(filename, ".*")
  path = File.join("dismantled", basename)
  if Dir.exist?(path)
    puts "| | [#{filename}]\n    skipped: folder at [#{path}] already exists"
    next
  end
  print "|*| [#{filename}] => [#{path}]\n    working... "
  Dir.mkdir(path)
  FtlFont.open(filename).dismantle_into(path)
  puts "done!"
end

puts("Done. Shutting down in 10 seconds...")
sleep(10.0)

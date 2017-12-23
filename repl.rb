#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require "ftl_font"
require "pry"

Dir["fonts/*.font"]
  .tap { |fns| puts "--- #{fns.size} files found" }
  .map(&FtlFont.method(:open))

Pry.start

#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path("../lib", __FILE__)

require "ftl_font"
require "pry"

@fonts = Dir[File.join("fonts", "*.font")]
         .tap { |fns| puts "--- #{fns.size} files found" }
         .map(&FtlFont::Binary::File.method(:open))

Pry.start

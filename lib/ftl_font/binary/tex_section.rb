# frozen_string_literal: true

require "bit-struct"
require "chunky_png"

module FtlFont
  module Binary
    # A section of the file labeled TEX. Effectively a bitmap with a bit
    # of metadata.
    class TexSection < BitStruct
      unsigned :fixed, 24
      octets :unknown1, 40
      unsigned :width, 16
      unsigned :height, 16
      octets :unknown2, 64
      unsigned :data_size, 32
      pad :padding, 64
      # 256 bits = 32 bytes total

      alias w width
      alias h height

      # Bitmap of 0x00s and 0xFFs
      rest :data

      def inspect
        summary = { w: w, h: h }
        "#<#{self.class} #{summary.inspect}>"
      end

      # Builds an in-memory PNG object that you can use for further processing
      # (like cutting out individual characters). Colors are inverted to
      # make the characters black on white.
      def png
        ChunkyPNG::Image.new(w, h, ChunkyPNG::Color::WHITE).tap do |png|
          data.bytes.each_slice(w).with_index do |slice, x|
            slice.each_with_index.each do |byte, y|
              png[y, x] = ChunkyPNG::Color.grayscale(255 - byte)
            end
          end
        end
      end
    end
  end
end

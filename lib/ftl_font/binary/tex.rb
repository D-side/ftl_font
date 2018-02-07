# frozen_string_literal: true

require "bit-struct"
require "chunky_png"

module FtlFont
  class Binary
    # A section of the file labeled TEX. Effectively a bitmap with a small
    # amount of metadata.
    class Tex < BitStruct
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
          data.bytes.each_slice(w).with_index do |slice, y|
            slice.each_with_index.each do |byte, x|
              png[x, y] = ChunkyPNG::Color.grayscale(byte)
            end
          end
        end
      end

      # Updates this section to contain the given image
      def png=(image)
        self.width = image.width
        self.height = image.height
        data = image.to_grayscale_stream
        # data = String.new(encoding: "binary")
        # width, height, data_size
        # (0...image.height).each do |y|
        #   (0...image.width).each { |x| data << (png[x, y] >> 16 & 0xff ) }
        #   puts "processed line #{y}"
        # end
        self.data = data
        self.data_size = data.size
        # byte = ChunkyPNG::Color.grayscale_teint(color)
      end
    end
  end
end

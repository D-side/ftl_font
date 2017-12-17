require "bit-struct"
require "chunky_png"

class FtlFont
  class TexSection < BitStruct
    unsigned :fixed, 24
    octets :unknown1, 40
    unsigned :width, 16
    unsigned :height, 16
    octets :unknown2, 64
    unsigned :data_size, 32
    pad :padding, 64
    # 256 bits = 32 bytes total
    rest :data # of 0x00s and 0xFFs

    # Builds an in-memory PNG object that you can use for
    # further processing (like cutting out individual characters).
    def png
      @png ||= ChunkyPNG::Image.new(
        width,
        height,
        ChunkyPNG::Color::WHITE).tap do |png|
        data.bytes.each_slice(width).with_index do |slice, x|
          slice.each_with_index.each do |byte, y|
            png[y, x] = byte == 0 ? ChunkyPNG::Color::WHITE : ChunkyPNG::Color::BLACK
          end
        end
      end
    end
  end
end

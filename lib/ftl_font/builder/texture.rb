module FtlFont
  module Builder
    # Provides a simplistic atlas builder that appends given images one by one,
    # keeping track of locations of individual images (by given keys).
    #
    # The packing algorithm works around a cursor that starts at the top-left
    # corner of the texture and appends images in a straight horizontal line
    # until there is no more room. Having reached the end of line, it begins
    # a new line, expanding the texture down as necessary.
    #
    # Images are placed with 1-pixel margin from one another, as done in the
    # original textures.
    class Texture
      WIDTH = 256
      DEFAULT_HEIGHT = 32
      MAX_HEIGHT = 1024 # sanity limit, should never be reached
      BACKGROUND = 0x00_00_00_ff

      # Texture being filled
      # => ChunkyPNG::Image
      attr_reader :texture

      # FIXME: layout storage doesn't belong here, all necessary layout details
      # are already yielded, the responsibility to keep track of it should lie
      # with the consumer

      # Atlas layout data: where's what
      # {
      #   key => {
      #     x: Integer,
      #     y: Integer,
      #     w: Integer,
      #     h: Integer
      #   },
      #   ...
      # }
      attr_reader :layout

      def initialize
        @texture = ChunkyPNG::Image.new(WIDTH, DEFAULT_HEIGHT, BACKGROUND)
        # Image layout data
        @layout = {}
        # Cursor coordinates
        @cursor_x = 0
        @cursor_y = 0
        @line_height = 0
      end

      # Appends the given PNG image and writes down its location (bounding box)
      # into the layout by the given key. Optionally accepts a block and yields
      # the top-left corner of the allocated space.
      def append_image!(image, key)
        reserve_space!(image.width, image.height, key) do |x, y|
          texture.replace!(image, x, y)
          yield x, y if block_given?
        end
      end

      # Reserves space of given dimensions on the texture, records resulting
      # bounding box in the layout and yields the top-left corner of the result.
      # Particularly useful for skipping space for blank symbols.
      def reserve_space!(w, h, key)
        raise "Key already exists: \"#{key}\"" if layout.key?(key)
        newline! unless can_fit_width?(w)
        ensure_line_height!(h)
        x = @cursor_x + 1
        y = @cursor_y + 1
        @cursor_x += w + 1
        yield x, y if block_given?
        layout[key] = { x: x, y: y, w: w, h: h }
      end

      def export(dir)
        texture.save(File.join(dir, "atlas.png"))
        File.write(
          File.join(dir, "atlas.json"),
          JSON.pretty_generate(layout),
          encoding: Encoding::UTF_8
        )
      end

      private

      # Check whether the given width can fit within the remainder of the line
      def can_fit_width?(width)
        @cursor_x + width + 1 < @texture.width
      end

      # Expands, if necessary, the line to fit another symbol of a given height
      def ensure_line_height!(height)
        @line_height = [height, @line_height].max
        ensure_texture_height!(@cursor_y + @line_height + 1)
      end

      # Starts a new line of images on the atlas
      def newline!
        @cursor_x = 0
        @cursor_y += @line_height + 1
        @line_height = 0
      end

      # Increases texture size until it reaches or exceeds the given height
      def ensure_texture_height!(height)
        loop do
          return if @texture.height >= height
          expand_texture!
        end
      end

      # Doubles the height of the texture, maintaining its contents
      def expand_texture!
        raise "Safety limit reached" if @texture.height * 2 > MAX_HEIGHT
        @texture = ChunkyPNG::Image.new(
          WIDTH, @texture.height * 2, BACKGROUND
        ).replace!(@texture)
      end
    end
  end
end

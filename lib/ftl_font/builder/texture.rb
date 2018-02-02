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
      BACKGROUND = 0xff_ff_ff_ff

      # Texture being filled
      # => ChunkyPNG::Image
      attr_reader :texture

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
      # into the layout by the given key.
      def append_image!(image, key)
        raise "Key already exists: \"#{key}\"" if layout.key?(key)
        newline! unless can_fit_width?(image.width)
        ensure_line_height!(image.height)
        # Calculate bounding box
        x = @cursor_x + 1
        y = @cursor_y + 1
        w = image.width
        h = image.height
        @cursor_x += w + 1
        texture.replace!(image, x, y)
        layout[key] = { x: x, y: y, w: w, h: h }
      end

      def export(dir, name)
        texture.save(File.join(dir, "#{name}.png"))
        File.write(File.join(dir, "#{name}.json"), JSON.pretty_generate(layout))
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

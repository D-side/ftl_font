module FtlFont
  module Builder
    # Builds a dataset out of character sets in dismantled state
    class CharacterList
      attr_reader :list

      def initialize
        @list = {}
      end

      def append_folder!(folder)
        index = File.join(folder, "index.json")
        JSON.parse(File.read(index, encoding: Encoding::UTF_8)).each do |char|
          if char["image"].is_a?(String)
            png = ChunkyPNG::Image.from_file(File.join(folder, char["image"]))
          end
          entry = { "png" => png }.merge(char)
          @list[char["character"]] = entry
        end
      end
    end
  end
end

require "zlib"

module Catalog
  module MagicTheGathering
    class LoadMtgjsonSqlite < ApplicationJob
      def perform
        if File.exist?(source_path)
          Zlib::GzipReader.open(source_path) { |gz|
            File.write(decompress_path, gz.read)
          }

          FileUtils.mv(decompress_path, target_path)
        end
      end

      private

      def decompress_path
        Rails.root.join("tmp/mtgjson/catalog_mtg.#{Rails.env}.sqlite")
      end

      def source_path
        Rails.root.join("tmp/mtgjson/#{FetchMtgjsonSqlite::FILENAME}")
      end

      def target_path
        Rails.root.join("storage/db/catalog_mtg.#{Rails.env}.sqlite")
      end
    end
  end
end

require "open-uri"
require "digest"

module Catalog
  module MagicTheGathering
    class FetchMtgjsonSqlite < ApplicationJob
      FILENAME = "AllPrintings.sqlite.gz"
      MTGJSON_FILE_URL = "https://mtgjson.com/api/v5/#{FILENAME}"
      MTGJSON_SHA_URL = "https://mtgjson.com/api/v5/#{FILENAME}.sha256"

      def perform(since: 1.week.ago, directory: Rails.root.join("tmp/mtgjson"))
        @since = since
        @directory = directory

        return if more_recent_download_exists?

        make_target_path
        download_mtgjson_data
        move_mtgjson_data_to_target
      end

      private

      attr_reader :since, :directory

      def database_target
        File.join(@directory, FILENAME)
      end

      def database_tempfile
        File.join(@directory, "#{FILENAME}.tmp")
      end

      def download_database
        URI.open(MTGJSON_FILE_URL)
      end

      def download_matches_sha
        Digest::SHA2.hexdigest(File.read(database_tempfile)) == sha_hash
      end

      def download_mtgjson_data
        IO.copy_stream(download_database, database_tempfile)
      end

      def make_target_path
        FileUtils.mkpath(@directory) unless File.exist?(database_target)
      end

      def more_recent_download_exists?
        File.exist?(database_target) && File.mtime(database_target) >= @since.to_time
      end

      def move_mtgjson_data_to_target
        FileUtils.mv(database_tempfile, database_target) if download_matches_sha
      end

      def sha_hash
        URI.open(MTGJSON_SHA_URL).read
      end
    end
  end
end

require "open-uri"
require "tempfile"
require "digest"

module Catalog
  module MagicTheGathering
    class FetchMtgjsonSqlite < ApplicationJob
      FILENAME = "AllPrintings.sqlite.xz"
      MTGJSON_FILE_URL = "https://mtgjson.com/api/v5/#{FILENAME}"
      MTGJSON_SHA_URL = "https://mtgjson.com/api/v5/#{FILENAME}.sha256"

      def perform(since: 1.week.ago, directory: Rails.root.join("tmp/mtgjson"))
        database_target = File.join(directory, FILENAME)
        return if File.exist?(database_target) && File.mtime(database_target) >= since.to_time

        database_tempfile = File.join(directory, "#{FILENAME}.tmp")
        database = URI.open(MTGJSON_FILE_URL)
        sha_hash = URI.open(MTGJSON_SHA_URL).read

        FileUtils.mkpath(directory)
        IO.copy_stream(database, database_tempfile)

        if Digest::SHA2.hexdigest(File.read(database_tempfile)) == sha_hash
          FileUtils.mv(database_tempfile, database_target)
        end
      end
    end
  end
end

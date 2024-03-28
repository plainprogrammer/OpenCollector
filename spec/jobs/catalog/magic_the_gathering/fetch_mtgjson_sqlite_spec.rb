require "rails_helper"

RSpec.describe Catalog::MagicTheGathering::FetchMtgjsonSqlite do
  subject(:job) { described_class.new }

  describe "MTGJSON Endpoint Checks" do
    let(:http_client) { Net::HTTP.new("mtgjson.com", 443) }
    let(:mtgjson_file_request) { http_client.head(URI(described_class::MTGJSON_FILE_URL).path) }
    let(:mtgjson_sha_request) { http_client.head(URI(described_class::MTGJSON_SHA_URL).path) }

    before do
      http_client.use_ssl = true
    end

    it { expect(mtgjson_file_request).to be_a_kind_of Net::HTTPSuccess }
    it { expect(mtgjson_sha_request).to be_a_kind_of Net::HTTPSuccess }
  end

  describe "#perform" do
    let(:target_file) { Rails.root.join("tmp/mtgjson/AllPrintings.sqlite.xz") }
    let(:backup_file) { "#{target_file}.bak" }

    before do
      FileUtils.mv(target_file, backup_file) if File.exist?(target_file)
    end

    after do
      FileUtils.mv(backup_file, target_file) if File.exist?(backup_file)
    end

    it "downloads the file" do
      expect {
        job.perform
      }.to change {
        Rails.root.join("tmp/mtgjson/AllPrintings.sqlite.xz").exist?
      }.from(false).to(true)
    end

    context "with :since argument" do
      context "and there is an existing file older than the :since argument" do
        before do
          FileUtils.touch(target_file)
          File.lutime(2.days.ago.to_time, 2.days.ago.to_time, target_file)
        end

        it "downloads the file" do
          expect {
            job.perform(since: 1.day.ago)
          }.to change {
            File.mtime(target_file)
          }
        end
      end

      context "and there is an existing file younger than the :since argument" do
        before do
          FileUtils.touch(target_file)
          expect(URI).not_to receive(:open)
        end

        it "does not download the file" do
          expect {
            job.perform(since: 1.day.ago)
          }.not_to change {
            Rails.root.join("tmp/mtgjson/AllPrintings.sqlite.xz").mtime
          }
        end
      end
    end
  end
end

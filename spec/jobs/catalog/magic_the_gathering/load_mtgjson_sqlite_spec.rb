require "rails_helper"

RSpec.describe Catalog::MagicTheGathering::LoadMtgjsonSqlite do
  subject(:job) { described_class.new }

  describe "#perform" do
    let(:target_file) { Rails.root.join("storage/db/catalog_mtg.#{Rails.env}.sqlite") }
    let(:backup_file) { "#{target_file}.bak" }

    before do
      FileUtils.mv(target_file, backup_file) if File.exist?(target_file)
    end

    after do
      FileUtils.mv(backup_file, target_file) if File.exist?(backup_file)
    end

    it "loads MTGJSON file to 'storage/db/catalog_mtg.test.sqlite'" do
      expect {
        job.perform
      }.to change {
        File.exist?(target_file)
      }.from(false).to(true)
    end

    context "when source file is not available" do
      let(:source_file) { Rails.root.join("tmp/mtgjson/#{Catalog::MagicTheGathering::FetchMtgjsonSqlite::FILENAME}") }
      let(:source_backup) { "#{source_file}.bak" }

      before do
        FileUtils.mv(source_file, source_backup) if File.exist?(source_file)
      end

      after do
        FileUtils.mv(source_backup, source_file) if File.exist?(source_backup)
      end

      it "does NOT load MTGJSON file" do
        expect {
          job.perform
        }.not_to change {
          File.exist?(target_file)
        }.from(false)
      end
    end
  end
end

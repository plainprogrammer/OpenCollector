require "rails_helper"

RSpec.describe "catalog:magic_the_gathering" do
  Rails.application.load_tasks

  describe "fetch_mtgjson_sqlite" do
    subject(:task) { Rake::Task["catalog:magic_the_gathering:fetch_mtgjson_sqlite"] }
    let(:job) { instance_double(Catalog::MagicTheGathering::FetchMtgjsonSqlite) }

    before do
      allow(Catalog::MagicTheGathering::FetchMtgjsonSqlite).to receive(:new).and_return(job)
    end

    it "perfoms the Catalog::MagicTheGathering::FetchMtgjsonSqlite job" do
      expect(job).to receive(:perform).and_return(true)
      task.invoke
    end
  end

  describe "load_mtgjson_sqlite" do
    subject(:task) { Rake::Task["catalog:magic_the_gathering:load_mtgjson_sqlite"] }
    let(:job) { instance_double(Catalog::MagicTheGathering::LoadMtgjsonSqlite) }

    before do
      allow(Catalog::MagicTheGathering::LoadMtgjsonSqlite).to receive(:new).and_return(job)
    end

    it "perfoms the Catalog::MagicTheGathering::LoadMtgjsonSqlite job" do
      expect(job).to receive(:perform).and_return(true)
      task.invoke
    end
  end

  describe "clean_mtgjson_downloads" do
    subject(:task) { Rake::Task["catalog:magic_the_gathering:clean_mtgjson_downloads"] }
    let(:target_file) { Rails.root.join("tmp/mtgjson/AllPrintings.sqlite.gz") }
    let(:target_path) { Rails.root.join("tmp/mtgjson") }
    let(:backup_path) { "#{target_path}_bak" }

    before do
      FileUtils.cp_r(target_path, backup_path) if Dir.exist?(target_path)
    end

    after do
      FileUtils.rm_rf(target_path) if Dir.exist?(target_path)
      FileUtils.mv(backup_path, target_path) if Dir.exist?(backup_path)
    end

    it "removes the compressed downloads" do
      expect {
        task.invoke
      }.to change {
        File.exist?(target_file)
      }.from(true).to(false)
    end
  end
end

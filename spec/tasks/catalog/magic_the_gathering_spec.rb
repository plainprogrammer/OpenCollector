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
end

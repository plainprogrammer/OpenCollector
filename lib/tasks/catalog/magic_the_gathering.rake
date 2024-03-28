namespace :catalog do
  namespace :magic_the_gathering do
    desc "Fetch MTGJSON SQLite data file"
    task fetch_mtgjson_sqlite: :environment do
      Catalog::MagicTheGathering::FetchMtgjsonSqlite.new.perform
    end
  end
end

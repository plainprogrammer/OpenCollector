module Catalog
  module MagicTheGathering
    class Record < ActiveRecord::Base
      self.abstract_class = true
      self.inheritance_column = nil
      establish_connection :catalog_mtg

      def readonly?
        true
      end
    end
  end
end

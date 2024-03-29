require "rails_helper"

RSpec.describe Catalog::MagicTheGathering::Record do
  subject { card.new }

  let(:card) do
    Class.new(described_class) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "card")
      end
    end
  end

  it { expect(described_class).to be_abstract_class }
  it { expect(described_class.inheritance_column).to be_blank }

  it { is_expected.to be_readonly }
end

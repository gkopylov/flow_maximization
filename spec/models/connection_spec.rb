require 'spec_helper'

describe Connection do
  let(:connection) { create :connection }

  it { should have_db_column(:source_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:target_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:capacity).of_type(:integer).with_options(:default => 10) }

  it { should have_db_column(:cost).of_type(:integer).with_options(:default => 10, :null => false) }

  it { should validate_presence_of(:source_id) }

  it { should validate_presence_of(:target_id) }

  it { should have_db_index([:source_id, :target_id]).unique(:true) }

  it { connection; should validate_uniqueness_of(:source_id).scoped_to(:target_id) }

  it { should have_db_index(:target_id) }

  it { should belong_to :source }

  it { should belong_to :target }
end

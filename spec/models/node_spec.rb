require 'spec_helper'

describe Node do
  let(:node) { create :node }

  it { should have_db_column(:project_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:name).of_type(:string) }

  it { should have_db_column(:left).of_type(:integer).with_options(:default => 0) }

  it { should have_db_column(:top).of_type(:integer).with_options(:default => 0) }

  it { should have_db_index(:project_id) }

  it { should validate_presence_of(:project_id) }

  it { should belong_to :project }

  it { should have_many(:connections).dependent(:destroy) }

  it { should have_many(:requests).dependent(:destroy) }

  it { should have_many(:nodes) }
end

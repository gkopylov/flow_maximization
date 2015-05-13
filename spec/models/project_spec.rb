require 'spec_helper'

describe Project do
  let(:project) { create :project }

  it { should have_db_column(:user_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:name).of_type(:string).with_options(:null => false) }

  it { should have_db_index(:name).unique(true) }

  it { should have_db_index(:user_id) }

  it { should validate_presence_of(:user_id) }

  it { should validate_presence_of(:name) }

  it { project; should validate_uniqueness_of(:name) }

  it { should belong_to :user }

  it { should have_many(:nodes).dependent(:destroy) }
end

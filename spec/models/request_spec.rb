require 'spec_helper'

describe Request do
  let(:request) { create :request }

  it { should have_db_column(:source_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:target_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:project_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:lifetime).of_type(:integer).with_options(:default => 10, :null => false) }

  it { should have_db_column(:size).of_type(:integer).with_options(:default => 10, :null => false) }

  it { should have_db_column(:start_time).of_type(:integer).with_options(:default => 0, :null => false) }

  it { should have_db_column(:success).of_type(:boolean) }

  it { should have_db_column(:path).of_type(:text) }

  it { should validate_presence_of(:source_id) }

  it { should validate_presence_of(:target_id) }

  it { should validate_presence_of(:start_time) }

  it { should validate_presence_of(:size) }

  it { should validate_presence_of(:lifetime) }

  it { should validate_numericality_of(:lifetime).only_integer }

  it { should validate_numericality_of(:size).only_integer }

  it { should validate_numericality_of(:start_time).only_integer }

  it { should have_db_index([:source_id, :target_id]) }

  it { should have_db_index(:target_id) }

  it { should have_db_index(:lifetime) }

  it { should have_db_index(:start_time) }

  it { should belong_to :source }

  it { should belong_to :target }

  it { should belong_to :project }

  it 'should validate source and target ids' do
    request.should be_valid    

    request.source_id = 1

    request.target_id = 1

    request.should_not be_valid
  end
end

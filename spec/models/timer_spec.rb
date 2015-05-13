require 'spec_helper'

describe Timer do
  let(:connection) { create :connection }

  it { should have_db_column(:project_id).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:time).of_type(:integer).with_options(:null => false) }

  it { should have_db_column(:capacities_matrix_text).with_options(:null => false) }

  it { should validate_presence_of(:time) }

  it { should validate_presence_of(:project_id) }

  it { should validate_presence_of(:capacities_matrix_text) }

  it { should have_db_index(:project_id) }

  it { should have_db_index(:time) }
end

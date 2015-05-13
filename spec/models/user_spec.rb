require 'spec_helper'

describe User do
  let(:user) { create :user }

  it { should have_db_column(:email).of_type(:string).with_options(:null => false) }

  it { should validate_presence_of(:email) }

  it { should validate_uniqueness_of(:email) }

  it { should have_many :projects }
end

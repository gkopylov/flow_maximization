require 'rails_helper'

describe UsersController, :type => :controller do
  let(:user) { create :user }

  it { should route(:get, '/users/1').to(:action => :show, :id => 1) }

  describe 'GET show' do
    before { get :show, :id => user }

    it { should render_template :show }

    it { expect(assigns(:user)).not_to be_nil }
  end
end

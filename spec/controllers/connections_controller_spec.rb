require 'rails_helper'

describe ConnectionsController, :type => :controller do
  let(:user) { create :user }
 
  let(:project) { create :project, :user => user }

  let(:connection) { create :connection, :source => (create :node, :project => project),
    :target => (create :node, :project => project) }

  it { should route(:post, '/connections').to(:action => :create) }

  it { should route(:put, '/connections/1').to(:action => :update, :id => 1) }

  it { should route(:delete, '/connections/1').to(:action => :destroy, :id => 1) }

  describe 'PUT update' do
    before { put :update, :id => connection }

    it { should redirect_to root_url }
  end

  describe 'DELETE destroy' do
    before { delete :destroy, :id => connection }

    it { should redirect_to root_url }
  end

  context 'User' do
    before { sign_in user }

    describe 'PUT update as JS' do
      before { put :update,  :id => connection, :connection => { :capacity => 20 }, :format => :js }

      it { assigns(:connection).capacity.should eq(20) }
    end
  end
end

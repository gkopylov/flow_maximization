require 'rails_helper'

describe NodesController, :type => :controller do
  let(:user) { create :user }
 
  let(:project) { create :project, :user => user }

  let(:node) { create :node, :project => project }

  it { should route(:post, '/projects/1/nodes').to(:action => :create, :project_id => 1) }

  it { should route(:put, '/projects/1/nodes/1').to(:action => :update, :id => 1, :project_id => 1) }

  it { should route(:delete, '/projects/1/nodes/1').to(:action => :destroy, :id => 1, :project_id => 1) }

  describe 'POST create' do
    before { post :create, :project_id => project, :node => { :foo => 'bar' } }

    it { should redirect_to root_url }
  end

  describe 'PUT update' do
    before { put :update, :id => node, :project_id => project }

    it { should redirect_to root_url }
  end

  describe 'DELETE destroy' do
    before { delete :destroy, :id => node, :project_id => project }

    it { should redirect_to root_url }
  end

  context 'User' do
    before { sign_in user }

    describe 'POST create as JS' do
      before { post :create, :node => { :left => '0', :top => '0'}, :project_id => project, :format => :js }

      it { should render_template :create }

      it { expect(assigns(:node)).not_to be_nil }
    end

    describe 'PUT update as JS' do
      before { put :update,  :id => node, :node => { :name => 'new name' }, :project_id => project, :format => :js }

      it { should render_template :update }

      it { assigns(:node).name.should eq('new name') }
    end
  end
end

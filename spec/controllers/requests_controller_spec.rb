require 'rails_helper'

describe RequestsController, :type => :controller do
  let(:user) { create :user }
 
  let(:project) { create :project, :user => user }

  let(:request) { create :request, :project => project }

  it { should route(:post, '/projects/1/requests').to(:action => :create, :project_id => 1) }

  it { should route(:put, '/projects/1/requests/1').to(:action => :update, :id => 1, :project_id => 1) }

  it { should route(:delete, '/projects/1/requests/1').to(:action => :destroy, :id => 1, :project_id => 1) }

  it { should route(:get, '/projects/1/requests/1/edit').to(:action => :edit, :id => 1, :project_id => 1) }

  describe 'POST create' do
    before { post :create, :project_id => project, :request => { :foo => 'bar'} }

    it { should redirect_to root_url }
  end

  describe 'PUT update' do
    before { put :update, :id => request, :project_id => project }

    it { should redirect_to root_url }
  end

  describe 'DELETE destroy' do
    before { delete :destroy, :id => request, :project_id => project }

    it { should redirect_to root_url }
  end

  context 'User' do
    before { sign_in user }

    describe 'POST create as JS' do
      before do 
        post :create, :request => { :source_id => 1, :target_id => 2, :size => 10, :start_time => 10}, 
          :project_id => project, :format => :js
      end

      it { should render_template :create }

      it { expect(assigns(:request)).not_to be_nil }
    end

    describe 'PUT update as JS' do
      before { put :update,  :id => request, :request => { :size => 15 }, :project_id => project, :format => :js }

      it { should render_template :update }

      it { assigns(:request).size.should eq(15) }
    end
  end
end

require 'rails_helper'

describe ProjectsController, :type => :controller do
  let(:user) { create :user }
  
  let(:project) { create :project, :user => user }

  it { should route(:get, '/projects').to(:action => :index) }

  it { should route(:post, '/projects').to(:action => :create) }

  it { should route(:get, '/projects/new').to(:action => :new) }

  it { should route(:get, '/projects/1/edit').to(:action => :edit, :id => 1) }

  it { should route(:get, '/projects/1').to(:action => :show, :id => 1) }

  it { should route(:put, '/projects/1').to(:action => :update, :id => 1) }

  it { should route(:delete, '/projects/1').to(:action => :destroy, :id => 1) }
  
  it { should route(:get, '/projects/1/start').to(:action => :start, :project_id => 1) }

  describe 'GET index' do
    before { get :index }

    it { should render_template(:index) }

    it { expect(assigns(:projects)).not_to be_nil }
  end

  describe 'POST create' do
    before { post :create, :project => { :foo => 'bar' } }

    it { should redirect_to root_url }
  end

  describe 'GET new' do
    before { get :new }

    it { should redirect_to root_url }
  end

  describe 'GET edit' do
    before { get :edit, :id => project }

    it { should redirect_to root_url }
  end

  describe 'GET show' do
    before { get :show, :id => project }

    it { should render_template :show }

    it { expect(assigns(:project)).not_to be_nil }
  end

  describe 'PUT update' do
    before { put :update, :id => project }

    it { should redirect_to root_url }
  end

  describe 'DELETE destroy' do
    before { delete :destroy, :id => project }

    it { should redirect_to root_url }
  end

  context 'User' do
    before { sign_in user }

    describe 'GET index' do
      before { get :index }

      it { should render_template(:index) }

      it { expect(assigns(:projects)).not_to be_nil }
    end

    describe 'POST create with valid params' do
      before { post :create, :project => attributes_for(:project) }

      it { should redirect_to assigns(:project) }

      it { expect(assigns(:project)).not_to be_nil }
    end

    describe 'POST create with invalid params' do
      before { post :create, :project => { :foo => 'bar' } }

      it { should render_template :new }

      it { expect(assigns(:project)).not_to be_nil }
    end

    describe 'GET new' do
      before { get :new }

      it { should render_template :new }

      it { expect(assigns(:project)).not_to be_nil }
    end

    describe 'GET edit' do
      before { get :edit, :id => project }

      it { should render_template :edit }

      it { expect(assigns(:project)).not_to be_nil }
    end

    describe 'GET show' do
      before { get :show, :id => project }

      it { should render_template :show }

      it { expect(assigns(:project)).not_to be_nil }
    end

    describe 'GET start as JS' do
      before { get :start, :project_id => project, :format => :js }

      it { should render_template :start }

      it { expect(assigns(:project)).not_to be_nil }
    end

    describe 'PUT update with valid params' do
      before { put :update,  :id => project, :project => { :name => 'new name' }}

      it { should redirect_to assigns(:project) }

      it { assigns(:project).name.should eq('new name') }
    end

    describe 'DELETE destroy' do
      before { delete :destroy, :id => project }

      it { should redirect_to projects_url }
    end
  end
end

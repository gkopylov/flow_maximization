class ProjectsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  load_and_authorize_resource :user

  load_and_authorize_resource :project, :through => :user, :shallow => true

  def index 
    @projects = Project.includes(:user).order('created_at desc').page params[:page]
  end

  def create
    if @project.save
      redirect_to @project
    else
      render :new
    end
  end

  def update
    if @project.update_attributes(resource_params)
      redirect_to @project
    else
      render :edit
    end
  end

  def destroy
    if @project.destroy
      redirect_to projects_url
    else
      render :index
    end
  end

  def max_flow
    @project = Project.find params[:project_id]

    @max_flow = @project.max_flow
  end

  def show_request_form
    @project = Project.find params[:project_id] 
  end

  def start
    @project = Project.find params[:project_id]

    @requests = @project.start
  end

  private

  def resource_params
    params.require(:project).permit(:name)
  end
end

class RequestsController < ApplicationController
  load_and_authorize_resource :project

  load_and_authorize_resource :request, :through => :project

  def create
    if @request.save
      render
    else
      render :js => 'alert("There are some errors that prevents to save the request");'
    end
  end

  def update
    if @request.update_attributes(resource_params)
      render
    else
      render :js => 'alert("There are some errors that prevents to update the request");'
    end
  end

  def destroy
    if @request.destroy
      render
    else
      render :js => 'alert("There are some errors that prevents to destroy the request");'
    end
  end

  private

  def resource_params
    params.require(:request).permit(:lifetime, :size, :source_id, :target_id, :project_id, :start_time, :success, :path)
  end
end

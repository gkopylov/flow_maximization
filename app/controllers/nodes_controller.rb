class NodesController < ApplicationController
  load_and_authorize_resource :project

  load_and_authorize_resource :node, :through => :project
  
  def create
    if @node.save
      render
    else
      render :js => 'alert("There are some errors that prevents to save the node");'
    end
  end

  def update
    if @node.update_attributes(resource_params)
      render
    else
      render :js => 'alert("There are some errors that prevents to update the node");'
    end
  end

  def destroy
    if @node.destroy
      render
    else
      render :js => 'alert("There are some errors that prevents to destroy the node");'
    end
  end

  def resource_params
    params.require(:node).permit(:left, :top, :name)
  end
end

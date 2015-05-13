class ConnectionsController < ApplicationController
  before_filter :create_connection, :only => :create

  load_and_authorize_resource

  def create
    if @connection.save
      render :text => 'success'
    else
      render :js => 'alert("There are some errors that prevents to save the connection");'
    end
  end

  def update
    if @connection.update_attributes(resource_params)
      render :text => 'success'
    else
      render :js => 'alert("There are some errors that prevents to update the node");'
    end
  end

  def destroy
    if @connection.destroy
      render :text => 'success'
    else
      render :js => 'alert("There are some errors that prevents to destroy the node");'
    end
  end

  def delete_by_nodes
    render :text => 'failure' and return unless (params[:source_id].present? && params[:target_id].present?)

    connection = Connection.
      find_by_source_id_and_target_id(params[:source_id].sub('node_', ''), params[:target_id].sub('node_', ''))

    if connection.destroy
      render :text => 'success'
    else
      render :text => 'failure'
    end
  end

  def find_by_nodes
    render :nothing => true and return unless (params[:source_id].present? && params[:target_id].present?)

    @connection = Connection.
      find_by_source_id_and_target_id(params[:source_id].sub('node_', ''), params[:target_id].sub('node_', ''))

    if @connection.present?
      render
    else
      render :nothing => true
    end
  end

  private

  def create_connection
    @connection = Connection.new(resource_params)

    @connection.source_id = resource_params[:source_id].sub('node_', '')

    @connection.target_id = resource_params[:target_id].sub('node_', '')
  end

  def resource_params
    params.require(:connection).permit(:capacity, :cost, :source_id, :target_id)
  end
end

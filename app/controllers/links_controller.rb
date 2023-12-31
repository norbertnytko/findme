# TODO: Use command bus and handler

class LinksController < ApplicationController
  def create
    @one_pager = OnePager.find_by_slug(params[:one_pager_slug])

    repository = OnePagers::Repository.new
    id = SecureRandom.uuid

    @link = @one_pager.links.build(link_params.merge(id: id))

    repository.with_one_pager(@one_pager.id) do |one_pager|
      one_pager.add_link(name: link_params[:name], url: link_params[:url], link_id: id)
    end
  end

  def edit
    @one_pager = OnePager.find_by_slug(params[:one_pager_slug])
    @link = @one_pager.links.find_by_id(params[:id])

    respond_to do |format|
      format.turbo_stream
    end
  end

  def update
    repository = OnePagers::Repository.new
    @link = Link.find(params[:id])
    @one_pager = OnePager.find_by_slug(params[:one_pager_slug])

    repository.with_one_pager(@one_pager.id) do |one_pager|
      one_pager.reorder_links(link_id: params[:id], new_position: link_params[:position].to_i) if link_params[:position].present?
      one_pager.change_link_name(link_id: params[:id], name: link_params[:name]) if link_params[:name].present?
      one_pager.change_link_url(link_id: params[:id], url: link_params[:url]) if link_params[:url].present?
    end

    @link.reload # TODO: Think about this

    respond_to do |format|
      format.turbo_stream
      format.json { head :no_content }
      format.html { head :no_content }
    end
  end

  def destroy
    repository = OnePagers::Repository.new
    @link = Link.find(params[:id])
    @one_pager = OnePager.find_by_slug(params[:one_pager_slug])
  
    repository.with_one_pager(@one_pager.id) { |one_pager| one_pager.remove_link(link_id: @link.id) }

    respond_to do |format|
      format.turbo_stream
    end
  end

  def fields
    @one_pager = OnePager.find_by_slug(params[:one_pager_slug])
    @link = Link.new

    respond_to do |format|
      format.turbo_stream
    end
  end

  def discard_fields
    @one_pager = OnePager.find_by_slug(params[:one_pager_slug])

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def link_params
    params.require(:link).permit(:name, :url, :position)
  end
end

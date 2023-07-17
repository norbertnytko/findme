# TODO: Use command bus and handler

class LinksController < ApplicationController
  def create
    repository = OnePagers::OnePagerRepository.new
    id = SecureRandom.id

    repository.with_one_pager(id) do |one_pager|
      one_pager.add_link(name: link_params[:name], url: link_params[:url])
    end
  end

  def update
    repository = OnePagers::OnePagerRepository.new
    link = Link.find(params[:id])

    repository.with_one_pager(link.one_pagers_id) do |one_pager|
      one_pager.change_link_name(link_id: params[:id], name: link_params[:name]) if link_params[:name].present?
      one_pager.change_link_url(link_id: params[:id], url: link_params[:url]) if link_params[:url].present?
    end
  end

  def destroy
    repository = OnePagers::OnePagerRepository.new
    link = Link.find(params[:id])
  
    repository.with_one_pager(link.one_pagers_id) { |one_pager| one_pager.remove_link(link_id: params[:id]) }

    respond_to do |format|
      format.html { redirect_to edit_one_pager_path(params[:one_pager_slug]), notice: 'Link removed' }
    end
  end

  private

  def link_params
    params.require(:link).permit(:name, :url)
  end
end

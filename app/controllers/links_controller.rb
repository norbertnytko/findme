class LinksController < ApplicationController
  def create
  end

  def update
  end

  def destroy
    repository = OnePagers::OnePagerRepository.new
    link = LinkReadModel.find(params[:id])
  
    repository.with_one_pager(link.one_pager_read_models_id) { |one_pager| one_pager.remove_link(link_id: params[:id]) }

    respond_to do |format|
      format.html { redirect_to edit_one_pager_path(params[:one_pager_slug]), notice: 'Link removed' }
    end
  end
end

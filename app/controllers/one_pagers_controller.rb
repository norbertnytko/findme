class OnePagersController < ApplicationController
  layout "admin", only: [:edit]


  def show
    @one_pager = OnePagerReadModel.find_by_slug(params[:id])
  end

  def edit
    @one_pager = OnePagerReadModel.find_by_slug(params[:id])
  end

  def update
    @one_pager = OnePagerReadModel.find_by_slug(params[:id])

    id = @one_pager.id
    repo = OnePagers::OnePagerRepository.new
    repo.with_one_pager(id) { |one_pager| one_pager.select_theme(theme: params[:one_pager_read_model][:theme]) }
  end
end

class OnePagersController < ApplicationController
  layout "admin", only: [:edit]


  def show
    @one_pager = OnePagerReadModel.find_by_slug(params[:id])
  end

  def edit
    @one_pager = OnePagerReadModel.find_by_slug(params[:id])
  end
end

class OnePagersController < ApplicationController
  def show
    @one_pager = OnePagerReadModel.find_by_slug(params[:id])
  end
end

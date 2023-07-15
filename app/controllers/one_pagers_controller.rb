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

    cmd = OnePagers::Commands::SelectTheme.new(aggregate_id: @one_pager.id, theme: params[:one_pager_read_model][:theme])
    command_bus.(cmd)
  end
end

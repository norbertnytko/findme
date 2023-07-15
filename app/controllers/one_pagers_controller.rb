class OnePagersController < ApplicationController
  layout "admin", only: [:edit]

  def show
    @one_pager = OnePagerReadModel.find_by_slug(params[:slug])
  end

  def edit
    @one_pager = OnePagerReadModel.find_by_slug(params[:slug])
  end

  def update
    @one_pager = OnePagerReadModel.find_by_slug(params[:slug])

    cmd = OnePagers::Commands::SelectTheme.new(aggregate_id: @one_pager.id, theme: params[:one_pager][:theme])
    command_bus.(cmd)
  end

  private

  def one_pager_params
    params.require(:one_pager_read_model).permit(:theme)
  end
end

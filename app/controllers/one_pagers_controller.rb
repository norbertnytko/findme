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

    if one_pager_params[:theme].present?
      select_theme = OnePagers::Commands::SelectTheme.new(
        aggregate_id: @one_pager.id,
        theme: one_pager_params[:theme]
      )
      command_bus.(select_theme)
    end

    if one_pager_params[:name].present?
      assign_name = OnePagers::Commands::AssignName.new(
        aggregate_id: @one_pager.id,
        name: one_pager_params[:name]
      )
      command_bus.(assign_name)
    end

    respond_to do |format|
      format.html { redirect_to edit_one_pager_path(@one_pager.slug) }
      format.turbo_stream
    end
  end

  private

  def one_pager_params
    params.require(:one_pager).permit(:theme, :name)
  end
end

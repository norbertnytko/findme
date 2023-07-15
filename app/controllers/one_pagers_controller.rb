class OnePagersController < ApplicationController
  layout "one_pager", only: [:show]

  def index
    @one_pagers = OnePager.all
  end

  def show
    @one_pager = OnePager.find_by_slug(params[:slug])
  end

  def new
    @one_pager = OnePager.new
  end

  def create
    id = SecureRandom.uuid

    draft = OnePagers::Commands::Draft.new(aggregate_id: id)
    command_bus.(draft)

    assign_slug = OnePagers::Commands::AssignSlug.new(
      aggregate_id: id,
      slug: one_pager_params[:slug]
    )
    
    command_bus.(assign_slug)

    if one_pager_params[:name].present?
      assign_name = OnePagers::Commands::AssignName.new(
        aggregate_id: id,
        name: one_pager_params[:name]
      )
      command_bus.(assign_name)
    end

    redirect_to edit_one_pager_path(one_pager_params[:slug])
  end

  def edit
    @one_pager = OnePager.find_by_slug(params[:slug])
  end

  def update
    @one_pager = OnePager.find_by_slug(params[:slug])

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

    redirect_to edit_one_pager_path(@one_pager)
  end

  private

  def one_pager_params
    params.require(:one_pager).permit(:theme, :name, :slug)
  end
end

class OnePagersController < ApplicationController
  layout "one_pager", only: [:show]

  class UpdateOnePagerForm < Infra::Form
    attribute :name, :string
    attribute :theme, :string
  
    command OnePagers::Commands::AssignName, fields: %i(name)
    command OnePagers::Commands::SelectTheme, fields: %i(theme)
  end

  class CreateOnePagerForm < Infra::Form
    attribute :slug, :string
    attribute :name, :string
  
    command OnePagers::Commands::Draft, fields: []  # No fields for Draft command
    command OnePagers::Commands::AssignSlug, fields: %i(slug)
    command OnePagers::Commands::AssignName, fields: %i(name)
  
    validates :slug, presence: true
  end

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

    create_one_pager_form = CreateOnePagerForm.new(
      slug: one_pager_params[:slug],
      name: one_pager_params[:name],
      aggregate_id: id
    )

    binding.pry
    if create_one_pager_form.submit(command_bus)
      flash[:notice] = 'One Pager created successfully'
      redirect_to edit_one_pager_path(create_one_pager_form.slug)
    else
      flash.now[:error] = create_one_pager_form.errors.full_messages
      render :new
    end
  end

  def edit
    @one_pager = OnePager.find_by_slug(params[:slug])
  end

  def update
    @one_pager = OnePager.find_by_slug(params[:slug])

    update_one_pager_form = UpdateOnePagerForm.new(
      aggregate_id: @one_pager.id,
      theme: one_pager_params[:theme],
      name: one_pager_params[:name],
      existing_data: @one_pager.attributes
    )

    if update_one_pager_form.submit(command_bus)
      flash[:notice] = 'One Pager updated successfully'
      redirect_to edit_one_pager_path(@one_pager)
    else
      flash.now[:error] = update_one_pager_form.errors.full_messages
      render :edit
    end
  end

  private

  def one_pager_params
    params.require(:one_pager).permit(:theme, :name, :slug)
  end
end

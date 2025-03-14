class ExperienceLevelsController < ApplicationController
  before_action :check_user_is_admin
  def index
    @experience_levels = ExperienceLevel.all
  end

  def new
    @experience_level = ExperienceLevel.new
  end

  def create
    @experience_level = ExperienceLevel.new(experience_level_params)
    if @experience_level.save
      redirect_to experience_levels_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @experience_level = ExperienceLevel.find(params[:id])
  end

  def update
    @experience_level = ExperienceLevel.find(params[:id])
    if @experience_level.update(experience_level_params)
      redirect_to experience_levels_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def active
    @experience_level = ExperienceLevel.find(params[:id])
    @experience_level.active!
    redirect_back_or_to root_path
  end

  def archive
    @experience_level = ExperienceLevel.find(params[:id])
    @experience_level.archived!
    redirect_back_or_to root_path
  end

  private

  def experience_level_params
    params.require(:experience_level).permit(
      :name,
      :status
    )
  end

  def check_user_is_admin
    unless Current.user.admin?
      redirect_to root_path
    end
  end
end

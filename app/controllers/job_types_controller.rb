class JobTypesController < ApplicationController
  before_action :only_admin_access
  before_action :set_job_type, only: [ :edit, :update, :archive, :activate ]
  def index
    @job_types = JobType.all
  end

  def new
    @job_type = JobType.new
  end

  def create
    @job_type = JobType.new(job_type_params)
    if @job_type.save
      flash[:notice] = t ".success"
      redirect_to job_types_path
    else
      flash.now[:alert] = t ".alert"
      render "new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @job_type.update(job_type_params)
      flash[:notice] = t ".success"
      redirect_to job_types_path
    else
      flash.now[:alert] = t ".alert"
      render "edit", status: :unprocessable_entity
    end
  end

  def archive
    if @job_type.archived!
      flash[:notice] = t ".success"
    else
      flash.now[:alert] = t ".alert"
    end
    redirect_to job_types_path
  end

  def activate
    if @job_type.active!
      flash[:notice] = t ".success"
    else
      flash.now[:alert] = t ".alert"
    end
    redirect_to job_types_path
  end

  private

  def job_type_params
    params.require(:job_type).permit(:name, :status)
  end

  def set_job_type
    @job_type = JobType.find_by(id: params[:id])
    redirect_to root_path, alert: t(".not_found") unless @job_type
  end
end

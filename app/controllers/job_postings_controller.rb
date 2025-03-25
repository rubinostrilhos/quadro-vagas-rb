class JobPostingsController < ApplicationController
  allow_unauthenticated_access only: [ :show ]
  before_action :set_job_posting, only: [ :show, :archive, :post ]
  before_action :check_user, only: [ :archive, :post ]
  before_action :check_inactive_company_profile, only: %i[ show ]

  def show; end

  def new
    @job_posting = JobPosting.new
  end

  def create
    @job_posting = JobPosting.new(job_posting_params)
    @job_posting.company_profile = Current.user.company_profile
    if @job_posting.save
      redirect_to @job_posting, notice: t(".success")
    else
      flash[:alert] = t(".failure")
      render :new, status: :unprocessable_entity
    end
  end

  def archive
    if @job_posting.archived!
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failure")
    end
    redirect_to @job_posting
  end

  def post
    if @job_posting.published!
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failure")
    end
    redirect_to @job_posting
  end

  private

  def set_job_posting
    @job_posting = JobPosting.find(params[:id])
  end

  def check_user
    unless @job_posting.company_profile.user == Current.user
      redirect_to @job_posting, alert: t(".negated_access")
    end
  end

  def job_posting_params
    params.require(:job_posting).permit(:title, :salary, :salary_currency, :salary_period,
                                        :work_arrangement, :job_location, :job_type_id,
                                        :experience_level_id, :description, tag_list: [])
  end

  def check_inactive_company_profile
    redirect_to root_path if @job_posting.company_profile.status == "inactive" && !admin?
  end
end

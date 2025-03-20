class JobPostingsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  before_action :set_job_posting, only: %i[ show ]
  before_action :check_inactive_job_posting, only: %i[ show ]

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

  private

  def job_posting_params
    params.require(:job_posting).permit(:title, :salary, :salary_currency, :salary_period,
                                        :work_arrangement, :job_location, :job_type_id,
                                        :experience_level_id, :description, tag_list: [])
  end

  def set_job_posting
    @job_posting = JobPosting.find(params[:id])
  end

  def check_inactive_job_posting
    redirect_to root_path if @job_posting.status == "inactive" && !admin?
  end
end

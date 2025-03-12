class JobPostingsController < ApplicationController
  allow_unauthenticated_access only: [:show]

  def index
    @job_postings = Current.user.job_postings.page(params[:page]).per(10)
  end

  def show
    @job_posting = JobPosting.find(params[:id])
  end
end

class HomeController < ApplicationController
  allow_unauthenticated_access
  def index
    return @job_postings = JobPosting.all if Current.user.present?
    @job_postings = JobPosting.where(status: JobPosting.statuses[:published])
  end

  def search
    if params[:query].present?
      @job_postings = JobPosting.search_jobs(params[:query])

      if @job_postings.empty?
        @search_error = true
      end

      return render :index
    end
    redirect_to root_path, alert: t(".alert")
  end
end

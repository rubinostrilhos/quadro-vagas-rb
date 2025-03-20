# Delete all records from the database
JobPosting.delete_all
CompanyProfile.delete_all
User.delete_all
JobType.delete_all
ExperienceLevel.delete_all

# Creates three job types
[ "Full Time", "Part Time", "Freelance" ].each do |job_type_name|
  JobType.create!(name: job_type_name)
end

# Creates four experience levels
[ "Intern", "Junior", "Mid level", "Senior" ].each do |experience_level|
  ExperienceLevel.create!(name: experience_level)
end

# Creates three users
users = []
3.times do |n|
  users << User.create!(name: "User #{n}th", last_name: "Doe", email_address: "#{n}th@email.com", password: "password123", password_confirmation: "password123")
end

# Creates one admin
User.create!(name: 'Admin', last_name: 'Admin', email_address: 'admin@email.com', password: 'password123', password_confirmation: "password123", role: :admin)
# Creates three company profiles
3.times do |n|
  profile = CompanyProfile.new(user_id: users[n].id, name: "Company Name #{n}", website_url: "http://company#{n}.com", contact_email: "contact@company#{n}.com")
  profile.logo.attach(io: File.open(Rails.root.join('spec/support/files/logo.jpg')), filename: 'logo.jpg')
  profile.save!
end

# Creates three job postings
JobPosting.create!(title: "Dev React", company_profile: CompanyProfile.first, salary: "1000.00", salary_currency: :usd, salary_period: :monthly, work_arrangement: :remote,  job_type: JobType.first, experience_level: ExperienceLevel.first, description: "There’s nothing better than hiking along the rocky footpaths, accompanied only by the noise of cicadas. As the boat docks in the harbor, gaze upon white and blue houses, craggy cliffs, sweeping olive groves, and the dazzling blues of the Aegean sea.")
JobPosting.create!(title: "Dev Node", company_profile: CompanyProfile.second, salary: "5000.00", salary_currency: :usd, salary_period: :monthly, work_arrangement: :remote,  job_type: JobType.second, experience_level: ExperienceLevel.second, description: "There’s nothing better than hiking along the rocky footpaths, accompanied only by the noise of cicadas. As the boat docks in the harbor, gaze upon white and blue houses, craggy cliffs, sweeping olive groves, and the dazzling blues of the Aegean sea.")
JobPosting.create!(title: "Dev RoR", company_profile: CompanyProfile.last, salary: "10000.00", salary_currency: :usd, salary_period: :monthly, work_arrangement: :remote, job_type: JobType.last, experience_level: ExperienceLevel.last, description: "There’s nothing better than hiking along the rocky footpaths, accompanied only by the noise of cicadas. As the boat docks in the harbor, gaze upon white and blue houses, craggy cliffs, sweeping olive groves, and the dazzling blues of the Aegean sea.")

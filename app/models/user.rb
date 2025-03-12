class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :company_profile
  has_many :job_postings, through: :company_profile

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  enum :role, { regular: 0, admin: 10 }

  validates :name, :last_name, :email_address, :password, :password_confirmation, presence: true
  validates :email_address, uniqueness: { case_sensitive: false }
  validates :email_address, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, confirmation: true
  validates :password, length: { minimum: 6 }
  validate :email_address_is_not_equal_to_any_company_email, if: :email_address_present?

  private
  def email_address_present?
    self.email_address.present?
  end

  def email_address_is_not_equal_to_any_company_email
    if CompanyProfile.exists?(contact_email: self.email_address)
      errors.add(:email_address, I18n.t("errors.messages.invalid_email_already_registered"))
    end
  end
end

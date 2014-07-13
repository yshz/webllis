class ChangePasswordForm
  include ActiveModel::Model

  attr_accessor :object, :current_password, :new_password,
    :new_password_confirmation
  validates :new_password, length: 6..20, confirmation: true

  validate do
    unless Authenticator.new(object).authenticate(current_password)
      errors.add(:current_password, :wrong)
    end
  end

  def save
    if valid?
      object.password = new_password
      object.save!
    end
  end
end

class Contact
  include ActiveModel::Model

  attr_accessor :subject, :email, :message

  validates :subject, presence: true
  validates :email, presence: true, format: /\@/
  validates :message, presence: true

end

class User < ActiveRecord::Base
  before_save :ensure_authentication_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tinks, primary_key: "id", foreign_key: "user_id"
  has_many :apns_tokens, primary_key: "id", foreign_key: "user_id"
  has_many :friends, primary_key: "id", foreign_key: "user_id"
  has_many :bans, primary_key: "id", foreign_key: "user_id"
  has_many :invites, primary_key: "id", foreign_key: "user_id"

  def ensure_authentication_token
    if authentication_token.blank? || Time.now > token_expiration
      self.authentication_token = generate_authentication_token
      self.token_expiration = token_expiration_date
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.find_by(authentication_token: token)
    end
  end

  def token_expiration_date
    Time.now + (1)
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

end

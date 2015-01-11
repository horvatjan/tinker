class Ban < ActiveRecord::Base
  belongs_to :user, primary_key: "user_id", foreign_key: "id"
end

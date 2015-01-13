class UserMailer < ActionMailer::Base

  default from: 'jan.horvat@google.com'

  def newpassword(user)
    @user = user
    mail(to: @user.first.email, subject: 'New password').deliver
  end

end

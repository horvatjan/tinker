class UserMailer < ActionMailer::Base

  default from: 'no-reply@tinkerchat.com'

  def newpassword(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Tinker Chat: New password').deliver
  end

end

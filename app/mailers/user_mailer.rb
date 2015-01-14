class UserMailer < ActionMailer::Base

  default from: 'no-reply@tinkerchat.com'

  def newpassword(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Tinker Chat: New password').deliver
  end

  def emailconfirmation(user, email_confirmation_code)
    @user = user
    @email_confirmation_url = "https://morning-beyond-2497.herokuapp.com/api/v1/account_activation/" + email_confirmation_code
    mail(to: @user.email, subject: 'Tinker Chat: Account activation').deliver
  end

end

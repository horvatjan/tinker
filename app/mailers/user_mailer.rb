class UserMailer < ActionMailer::Base

  default from: 'no-reply@tinkchatapp.com'

  def newpassword(user, password)
    @user = user
    @password = password
    mail(to: @user.email, subject: 'Tinkchat - Password Reset').deliver
  end

  def emailconfirmation(user, email_confirmation_code)
    @user = user
    @email_confirmation_url = ENV['MANDRILL_HOST']+"account_activation/" + email_confirmation_code
    mail(to: @user.email, subject: 'Tinkchat - Complete Your Profile').deliver
  end

end

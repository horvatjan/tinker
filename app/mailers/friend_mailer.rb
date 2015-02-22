class FriendMailer < ActionMailer::Base

  default from: 'no-reply@tinkerchat.com'

  def send_invite(user, invitee)
    @user_name = user.first.name
    @invitee = invitee
    mail(to: @invitee, subject: @user_name + ' invited you to TinkChat').deliver
  end

end

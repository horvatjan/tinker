class FriendMailer < ActionMailer::Base

  default from: 'no-reply@tinkchatapp.com'

  def send_invite(user, invitee)
    @user_name = user.first.name
    @invitee = invitee
    mail(to: @invitee, subject: 'Tinkchat - Find out who is thinking of you').deliver
  end

end

class ContactMailer < ActionMailer::Base

  default from: 'no-reply@tinkerchat.com'

  def forward_contact_message(message_params)
    @subject = message_params[:subject]
    @message = message_params[:message]
    @email = message_params[:email]
    mail(to: 'jan.horvat@gmail.com', from: @email, subject: 'New message: ' + @subject).deliver
  end

end

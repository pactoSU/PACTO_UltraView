class ShareMailer < ActionMailer::Base
  default from: "pactoultraview@gmail.com"
  
  
  def share_email(user, email, url)
  @email = email
  @user = user
  @url  = url
  mail(to: @email, subject: @user+" wants to share an ultrasound with you!" )
  end
  
end

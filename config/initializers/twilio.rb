account_sid = ENV["TWILIO_SID"]
auth_token = ENV["TWILIO_TOKEN"]
sms_application_sid = ENV["TWILIO_SMS_APPLICATION_SID"]

Client = Twilio::REST::Client.new account_sid, auth_token

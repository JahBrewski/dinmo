desc "This task is called by the Heroku scheduler add-on"
task :clean_conversations => :environment do
  puts "Cleaning messages and conversations..."
  Conversation.clean_conversations
  Message.clean_messages
  puts "Done."
end

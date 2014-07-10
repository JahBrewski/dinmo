desc "This task is called by the Heroku scheduler add-on"
task :clean_conversations => :environment do
  puts "Cleaning numbers..."
  Conversation.clean_conversations
  puts "Done."
end

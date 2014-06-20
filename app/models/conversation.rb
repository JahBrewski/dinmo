class Conversation < ActiveRecord::Base
  belongs_to :pupil, class_name: "User"
  belongs_to :expert, class_name: "User"
  belongs_to :number
  attr_accessor :message
end

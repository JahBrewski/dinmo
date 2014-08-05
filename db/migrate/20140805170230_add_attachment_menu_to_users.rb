class AddAttachmentMenuToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :menu
    end
  end

  def self.down
    remove_attachment :users, :menu
  end
end

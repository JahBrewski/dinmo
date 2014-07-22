class AddRaterAndRatedIdsToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :rater_id, :integer
    add_column :ratings, :rated_id, :integer
  end
end

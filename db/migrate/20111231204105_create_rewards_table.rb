class CreateRewardsTable < ActiveRecord::Migration
  def up
  	create_table :rewards do |t|
		t.integer :company_id
		t.string :name
		t.string :description
		t.integer :points
		t.string :image_url
		t.timestamps
	end
  end

  def down
	drop_table :rewards
  end
end

class AddCodeToRace < ActiveRecord::Migration
	def change
		add_column :races, :code, :integer, :null => false
		Race.all.each{|r|r.update_attribute(:code, r.id)}
		add_index  :races, :code, :unique => true
	end
end

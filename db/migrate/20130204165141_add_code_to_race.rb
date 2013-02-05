class AddCodeToRace < ActiveRecord::Migration
	def up
		add_column :races, :code, :integer	#, :null => false
#	shouldn't do this, but it is needed before the index
		Race.all.each{|r|r.update_attribute(:code, r.id)}
		add_index  :races, :code, :unique => true
	end
	def down
#	can't really do this
#		Race.all.each{|r|r.update_attribute(:id, r.code)}
#	this would work, but could be a problem depending on the other ids
#	shouldn't need to copy the code back to the id anyway
#		Race.all.each{|r| Race.where(:code => r.code).update_all(:id => r.code)}
		remove_column :races, :code
#		add_index  :races, :code, :unique => true
	end
end

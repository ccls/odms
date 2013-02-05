class AddCodeToLanguage < ActiveRecord::Migration
	def up
		add_column :languages, :code, :integer	#	, :null => false
#	shouldn't do this, but it is needed before the index
		Language.all.each{|l|l.update_attribute(:code, l.id)}
		add_index  :languages, :code, :unique => true
	end
	def down
#	can't really do this
#		Language.all.each{|l|l.update_attribute(:id, l.code)}
#	this would work, but could be a problem depending on the other ids
#	shouldn't need to copy the code back to the id anyway
#		Language.all.each{|r| VitalStatus.where(:code => r.code).update_all(:id => r.code)}
		remove_column :languages, :code
#		add_index  :languages, :code, :unique => true
	end
end

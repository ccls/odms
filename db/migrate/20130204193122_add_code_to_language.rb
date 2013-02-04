class AddCodeToLanguage < ActiveRecord::Migration
	def up
		add_column :languages, :code, :integer, :null => false
#	shouldn't do this, but it is needed before the index
		Language.all.each{|l|l.update_attribute(:code, l.id)}
		add_index  :languages, :code, :unique => true
	end
	def down
#	can't really do this
#		Language.all.each{|l|l.update_attribute(:id, l.code)}
		remove_column :languages, :code
#		add_index  :languages, :code, :unique => true
	end
end

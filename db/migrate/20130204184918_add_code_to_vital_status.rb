class AddCodeToVitalStatus < ActiveRecord::Migration
	def up
#		For some reason, it is still there. (but no null false)
#		add_column :vital_statuses, :code, :integer, :null => false
#	shouldn't do this, but it is needed before the index
		VitalStatus.all.each{|v|v.update_attribute(:code, v.id)}
#	can't ":null => false" until has data
		change_column :vital_statuses, :code, :integer, :null => false
#		For some reason, it is still there.
#		add_index  :vital_statuses, :code, :unique => true
	end
	def down
#		VitalStatus.all.each{|v|v.update_attribute(:id, v.code)}
#		For some reason, it is still there.
#		add_column :vital_statuses, :code, :integer, :null => false
		change_column :vital_statuses, :code, :integer, :null => true
#		For some reason, it is still there.
#		add_index  :vital_statuses, :code, :unique => true
	end
end

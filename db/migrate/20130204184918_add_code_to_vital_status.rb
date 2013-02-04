class AddCodeToVitalStatus < ActiveRecord::Migration
	def up
#		For some reason, it is still there. (but no null false)
#		add_column :vital_statuses, :code, :integer, :null => false
		change_column :vital_statuses, :code, :integer, :null => false
		VitalStatus.all.each{|v|v.update_attribute(:code, v.id)}
#		For some reason, it is still there.
#		add_index  :vital_statuses, :code, :unique => true
	end
	def down
#		For some reason, it is still there.
#		add_column :vital_statuses, :code, :integer, :null => false
		change_column :vital_statuses, :code, :integer, :null => true
#		VitalStatus.all.each{|v|v.update_attribute(:code, v.id)}
#		For some reason, it is still there.
#		add_index  :vital_statuses, :code, :unique => true
	end
end

class AddLabelToProjects < ActiveRecord::Migration
	def change
		add_column :projects, :label, :string
	end
end

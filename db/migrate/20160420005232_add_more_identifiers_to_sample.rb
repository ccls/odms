class AddMoreIdentifiersToSample < ActiveRecord::Migration
	def change
		add_column :samples, :ucsf_item_no, :integer
		add_column :samples, :ucb_labno, :integer
		add_column :samples, :ucb_biospecimen_flag, :boolean
	end
end

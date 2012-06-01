class AddForNewSampleFlagToSampleTypes < ActiveRecord::Migration
	def change
		add_column :sample_types, :for_new_sample, :boolean, 
			:default => true, :null => false
	end
end

class AddT2kAndGeglToSampleType < ActiveRecord::Migration
	def change
		add_column :sample_types, :t2k_sample_type_id, :integer
		add_column :sample_types, :gegl_sample_type_id, :string, :length => 5
	end
end

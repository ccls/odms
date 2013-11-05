class AddSampleFormatToSamples < ActiveRecord::Migration
	def change
		add_column :samples, :sample_format, :string
	end
end

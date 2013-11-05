class AddSampleTemperatureToSamples < ActiveRecord::Migration
	def change
		add_column :samples, :sample_temperature, :string
	end
end

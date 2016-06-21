class AddMoreIdentifiers2ToSample < ActiveRecord::Migration
	def change
		add_column :samples, :cdc_id, :string, :limit => 25
		add_column :samples, :cdc_barcode_id, :string, :limit => 25
	end
end

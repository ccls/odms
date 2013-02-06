class ShortenAbstractsChemoProtocolNameFrom255To60 < ActiveRecord::Migration
	def up
		change_column :abstracts, :chemo_protocol_name, :string, :limit => 60
	end

	def down
		change_column :abstracts, :chemo_protocol_name, :string
	end
end

class ShortenAbstractsCy3LegacyFrom255To60 < ActiveRecord::Migration
	def up
		change_column :abstracts, :cy3_legacy, :string, :limit => 60
	end

	def down
		change_column :abstracts, :cy3_legacy, :string
	end
end

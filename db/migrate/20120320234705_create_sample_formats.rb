class CreateSampleFormats < ActiveRecord::Migration
	def change
		create_table :sample_formats do |t|
			t.integer :position
			t.string :key, :null => false
			t.string :description
			t.timestamps
		end
		add_index :sample_formats, :key, :unique => true
		add_index :sample_formats, :description, :unique => true
	end
end
__END__

This is my first rails 3 migration.

No more up and down methods?  Just a change method?

We shall see.

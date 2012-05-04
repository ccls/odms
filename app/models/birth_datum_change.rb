class BirthDatumChange; end
#class BirthDataChange < ActiveRecord::Base
#
##	gonna need this ...
##	validates_presence_of :birth_data_id
#
#end

#	This will probably just go away

__END__


class CreateBirthDatumChanges < ActiveRecord::Migration
	def change
		create_table :birth_datum_changes do |t|
			t.integer :birth_datum_update_id
			t.integer :birth_datum_id
			t.boolean :new_datum_record, :default => false, :null => false
			t.string  :modified_column
			t.string  :previous_value
			t.string  :new_value
			t.timestamps
		end
	end
end

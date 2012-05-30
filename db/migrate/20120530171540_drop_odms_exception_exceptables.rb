class DropOdmsExceptionExceptables < ActiveRecord::Migration
	def up
		drop_table :odms_exception_exceptables
	end

	def down
		create_table :odms_exception_exceptables do |t|
			t.integer :odms_exception_id
			t.integer :exceptable_id
			t.string :exceptable_type
			t.timestamps
		end
	end
end

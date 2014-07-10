class CreateAlternateContacts < ActiveRecord::Migration
	def change
		create_table :alternate_contacts do |t|
			t.belongs_to :study_subject, index: true
			t.string :name
			t.string :relation
			t.string :line_1
			t.string :line_2
			t.string :city
			t.string :state
			t.string :zip
			t.string :phone_number_1
			t.string :phone_number_2
			t.text   :notes
			t.timestamps
		end
	end
end

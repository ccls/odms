class ChangeSomeBirthDatumBooleansToStrings < ActiveRecord::Migration
	#	these values come in as Y, N, 1, 2, etc.
	#	initially they all appear to have been cast incorrectly
	#	changing to strings and reimporting the values
	def up
		change_column :birth_data, :vacuum_attempt_unsuccessful, :string
		change_column :birth_data, :mother_received_wic, :string
		change_column :birth_data, :forceps_attempt_unsuccessful, :string
		change_column :birth_data, :found_in_state_db, :string
	end
	def down
		change_column :birth_data, :vacuum_attempt_unsuccessful, :boolean
		change_column :birth_data, :mother_received_wic, :boolean
		change_column :birth_data, :forceps_attempt_unsuccessful, :boolean
		change_column :birth_data, :found_in_state_db, :boolean
	end
end

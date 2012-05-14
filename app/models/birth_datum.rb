class BirthDatum < ActiveRecord::Base

#	gotta use after_* so that have own id to pass

#	still need to know which field is the unique one.

	belongs_to :study_subject

	#	Fortunately, in rails 3, after_create seems to be called before after_save
	#	I don't think that this was true in rails 2.
	after_create :create_new_datum_record_change
#	after_save or after_update?
#	after_save   :create_datum_record_changes
	after_update :create_datum_record_changes

#	would be any birth data changes as all will be appended

	def create_new_datum_record_change
#		BirthDatumChange.create!({
#			:birth_datum_id        => self.id,
#			:birth_datum_update_id => self.birth_datum_update_id,
#			:new_datum_record      => true
#		})
	end

	def create_datum_record_changes
#		unignorable_changes.each do |field,values|
#			BirthDatumChange.create!({
#				:birth_datum_id        => self.id,
#				:birth_datum_update_id => self.birth_datum_update_id,
#				:new_datum_record      => false,
#				:modified_column      => field,
#				:previous_value       => values[0],
#				:new_value            => values[1]
#			})
#		end
	end

end

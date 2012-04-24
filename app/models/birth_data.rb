class BirthData < ActiveRecord::Base
#
#	Be advised the "data" pluralized is "data" which
#	means that this table name is "birth_data".
#	This inflection "problem" could be an issue elsehwere
#	if a difference between the singular and plural in expected.
#
#	This will be true in named routes.
#

#	gotta use after_* so that have own id to pass

#	still need to know which field is the unique one.

	#	Fortunately, in rails 3, after_create seems to be called before after_save
	#	I don't think that this was true in rails 2.
	after_create :create_new_data_record_change
	after_save   :create_data_record_changes


	def create_new_data_record_change
#		BirthDataChange.create!({
#			:birth_data_id   => self.id,
#			:new_data_record => true
#		})
	end

	def create_data_record_changes
#		unignorable_changes.each do |field,values|
#			BirthDataChange.create!({
#				:birth_data_id   => self.id,
#				:new_data_record => false,
#				:modified_column     => field,
#				:previous_value      => values[0],
#				:new_value           => values[1]
#			})
#		end
	end

end

module ActiveRecord
	class Relation

		#	rather than just joins(:some_association) INNER JOIN
		#	left_joins(:some_association) will build an OUTER LEFT JOIN
		def left_joins(*args)
			return self if args.compact.blank?

			relation = clone

			args.flatten!

			#	args could be just a single symbol
			#		...could be an array of symbols (
			#		...could be a hash (joins(:address => :address_type))
			#		...could be a string (SQL)

			#	here I really am just expecting an array of model names as a symbols

			#	this only works if the primary and foreign keys are conventional

			#	@klass (or its reader klass() ) is the calling class (Organization)
			#	@table (or its reader table() ) is the calling class's Arel::Table


#	StudySubject
# scope :join_patients, joins(
#   Arel::Nodes::OuterJoin.new(Patient.arel_table,Arel::Nodes::On.new(
#     self.arel_table[:id].eq(Patient.arel_table[:study_subject_id]))))
# scope :join_patients, left_joins(:patient)	#	WORKS

#	Organization
# scope :without_sample_location, joins(
#   Arel::Nodes::OuterJoin.new(
#     SampleLocation.arel_table,Arel::Nodes::On.new(
#       self.arel_table[:id].eq(SampleLocation.arel_table[:organization_id]))))
# scope :without_sample_location, left_joins(:sample_location)	#	WORKS
#
#	Organization has one Sample Location

# scope :without_hospital, joins(
#   Arel::Nodes::OuterJoin.new(
#     Hospital.arel_table,Arel::Nodes::On.new(
#       self.arel_table[:id].eq(Hospital.arel_table[:organization_id]))))
# scope :without_hospital, left_joins(:hospital)	#	WORKS

#	Organization has one Hospital


#		@zip_codes = ZipCode.joins(
#			Arel::Nodes::OuterJoin.new(County.arel_table,Arel::Nodes::On.new(
#				ZipCode.arel_table[:county_id].eq(County.arel_table[:id]))))
#
#		@zip_codes = ZipCode.left_joins(:county) #??? backwards? won't work?

#	ZipCode belongs to County



			args.each do |arg|	#	no, I'm not a pirate
				reflection = klass.reflections[arg]
				joining_model = reflection.klass
#
#	:has_one and probably :has_many	( BUT NOT :belongs_to )
#
				relation.joins_values += [
					Arel::Nodes::OuterJoin.new(
						joining_model.arel_table,
( reflection.macro == :belongs_to ) ?
						Arel::Nodes::On.new(
							table[ reflection.foreign_key ].eq(
								joining_model.arel_table[ :id ]
							)
						) :
						Arel::Nodes::On.new(
							table[:id].eq(		#	won't ALWAYS be :id
								joining_model.arel_table[ reflection.foreign_key ]
							)
						)

					)
				]




			end	#	args.each do |arg|	#	no, I'm not a pirate

			relation
		end

	end	#	class Relation
end	#	module ActiveRecord

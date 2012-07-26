#
#	Simply extracted some code to clean up model.
#	I'd like to do this to all of the really big classes
#	but let's see how this goes first.
#
module StudySubjectSunspot
def self.included(base)
#	Must delay the calls to these ActiveRecord methods
#	or it will raise many "undefined method"s.
base.class_eval do

searchable do
	integer :id	#	if find it odd that I must explicitly include id to order by it
	# fields for faceting or explicit field searching
#	string :subject_type
#		OR (difference?)
	integer :subject_type_id, :references => SubjectType
	string :vital_status
	string :case_control_type
	date :reference_date
	string :sex
	date :dob
	date :died_on
	string :phase
	integer :birth_year       #	actual birth_year attribute or parse year from dob???
	# fields for text searching
	# ALL ids and names
	# enrolled projects
	# sampleids
	# Phone numbers
#	string :biospecimens, :multiple => true

	
#    dynamic_integer :custom_category_ids, :multiple => true do 
#      custom_categories.inject(Hash.new { |h, k| h[k] = [] }) do |map, custom_category| 
#        map[custom_category.id] << custom_category_values_for(custom_category) 
#      end 
#    end 
#	dynamic_integer :enrollment_ids, :multiple => true do 
##	dynamic_string :my_enrollments, :multiple => true do 
#		enrollments.inject(Hash.new { |h, k| h[k] = {} }) do |map, enrollment| 
##		enrollments.inject(Hash.new { |h, k| h[k] = [] }) do |map, enrollment| 
#			#map[enrollment.id] << enrollment_values_for(enrollment) 
#			#map[enrollment.id] << { "enrollment_values_for(enrollment) KEY" =>  "enrollment_values_for(enrollment) value"}
#			map[enrollment.id] = enrollment.attributes
#			#map[enrollment.id] << enrollment.project.description
#		end 
#	end 
#https://github.com/sunspot/sunspot/issues/207


##		enrollments.inject(Hash.new { |h, k| h[k] = {} }) do |map, enrollment| 
#	dynamic_integer :enrollment_ids, :multiple => true do 
#		enrollments.inject({}) do |map, enrollment| 
#			map[enrollment.id] = enrollment.attributes
#		end 
#	end 
#> StudySubject.search{ dynamic(:enrollment_ids){ facet :project_id } }.facet(:enrollment_ids,:project_id).rows.first.count
#=> 1
#	StudySubject.search{ dynamic(:enrollment_ids){ with :project_id, 10 } }.results
#
#> StudySubject.search{ dynamic(:enrollment_ids){ with( :project_id, 10); facet :is_eligible } }.facets.first.rows.first.value
#=> 1




#	dynamic_string :custom_values do
#      key_value_pairs.inject({}) do |hash, key_value_pair|
#        hash[key_value_pair.key.to_sym] = key_value_pair.value
#      end
#   end
#	integer :enrollment_id, :references => Enrollment, :multiple => true

#	string :enrolled_projects, :multiple => true


	text :first_name
	text :middle_name
	text :maiden_name
	text :last_name
	text :mother_first_name
	text :mother_middle_name
	text :mother_maiden_name
	text :mother_last_name
	text :father_first_name
	text :father_middle_name
	text :father_last_name
	text :guardian_first_name
	text :guardian_middle_name
	text :guardian_last_name
	text :studyid
	text :icf_master_id
	text :childid
	text :patid
	text :hospital_no
	text :state_id_no
	text :state_registrar_no
	text :local_registrar_no
end if Sunspot::Rails::Server.new.running?
#
#	This condition is temporary, but does mean
#	that the server must be started FIRST.
#


#
#	Add something like ...
#	to associations that contain indexed data?
#
#  belongs_to :parent
#
#  after_save :reindex_parent!
#
#  def reindex_parent!
#    parent.index
#  end


#	bundle exec rake sunspot:solr:start # or sunspot:solr:run to start in foreground

#	def enrolled_projects
#		enrollments.collect(&:project).collect(&:description)
#	end

end	#	class_eval
end	#	included
end	#	StudySubjectSunspot

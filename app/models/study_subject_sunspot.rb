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
	string :subject_type
#		OR (difference?)
#	integer :subject_type_id, :references => SubjectType
	string :vital_status
#		OR (difference?)
#	integer :vital_status_id, :references => VitalStatus
#	Using the foreign key and 'references' seems to be faster
#	indexing, but then the facet values are the integers, not the string names
#	For the moment, I'm going to use the strings.  Perhaps in the future,
#	I'll find a better or more corect way.
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




#	develope a way to search for the NULLs and BLANKs
#		I don't think that NULL actually gets "faceted"
#	May have to explicitly assign it NULL or BLANK in index?

	


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
#	don't understand what is 'integer' about this
#	I also don't see how this is 'dynamic' either
#		it is just adding a prefix to the name.
#	I really need a better example
#	dynamic_integer :enrollment_ids, :multiple => true do 
#
#	This looks nice, but I'm not sure if it is actually doing what I want.
#	Almost.  Each enrollment overwrites the previous one so 
#	each subject ends up with just one enrollment.
#
#	dynamic_string :enrollments, :multiple => true do 
#		enrollments.inject({}) do |map, enrollment| 
##			map[enrollment.id] = enrollment.attributes
#			map[enrollment.id] = {
#				:project => enrollment.project.description,
#				:is_eligible => YNDK[enrollment.is_eligible],
#				:consented => YNDK[enrollment.consented]
#			}
#		end 
#	end 
#> StudySubject.search{ dynamic(:enrollment_ids){ facet :project_id } }.facet(:enrollment_ids,:project_id).rows.first.count
#=> 1
#	StudySubject.search{ dynamic(:enrollment_ids){ with :project_id, 10 } }.results
#
#> StudySubject.search{ dynamic(:enrollment_ids){ with( :project_id, 10); facet :is_eligible } }.facets.first.rows.first.value
#=> 1
#> StudySubject.search{ dynamic(:enrollment_ids){ with( :project_id, 10); facet :is_eligible } }.facets.first.name
#=> :"enrollment_ids:is_eligible"



#	dynamic_string :custom_values do
#      key_value_pairs.inject({}) do |hash, key_value_pair|
#        hash[key_value_pair.key.to_sym] = key_value_pair.value
#      end
#   end
#	integer :enrollment_id, :references => Enrollment, :multiple => true

#	string :enrolled_projects, :multiple => true do
#		enrollments.collect(&:project).collect(&:description)
#	end

#	string "enrollments:project".to_sym, :multiple => true

#
#    dynamic_string :enrollments, :multiple => true do
#      enrollments.collect do |enrollment|
#			enrollment.inject({}) do |hash, pair|
#        hash.merge(pair.key.to_sym => pair.value)
#      end
#      end
#    end


#
#	The following at least indexes.  This may come down to creating
#	fields on the fly
#

##
##	how to access enrollments as is study_subject association? 
##  NOT HERE AS IN CLASS! NOT INSTANCE!
##	NoMethodError: undefined method `enrollments' for #<Sunspot::DSL::Fields:0x00000102c6ecf8>
##	Only seems accessible inside the dsl blocks
##puts Project.all.collect(&:to_s)#	works
## what would happen if another project were created after start? Reindex all subjects?
##	dynamic facets in "enrollment_#{project.underscore}" namespace???
#		integer "enrollment_#{project.underscore}_consented" do











	string :projects, :multiple => true do
		enrollments.collect(&:project).collect(&:to_s)
	end
	Project.all.each do |project|
#
#	Use the integer values or convert to YNDK text?
#
#		dynamic_string "project_#{project.to_s.downcase.gsub(/\W+/,'_')}" do
#			(enrollments.where(:project_id => project.id).first.try(:attributes) || {})
#				.select{|k,v|['consented','is_eligible'].include?(k) }
#
#	> {:a=>1}.inject({}){|h,pair| h.merge(pair[0] => YNDK[pair[1]]) }
#	=> {:a=>"Yes"}
#
#		end
#		dynamic_integer "project_#{project.to_s.downcase.gsub(/\W+/,'_')}" do
#		dynamic_integer "project_#{project.html_friendly}" do
#			(enrollments.where(:project_id => project.id).first.try(:attributes) || {})
#				.select{|k,v|['consented','is_eligible'].include?(k) }
		dynamic_string "project_#{project.html_friendly}" do
			(enrollments.where(:project_id => project.id).first.try(:attributes) || {})
				.select{|k,v|['consented','is_eligible'].include?(k) }
				.inject({}){|h,pair| h.merge(pair[0] => YNDK[pair[1]]||'NULL') }
		end
	end








#
#	Uncomment if want full text searching
#	I don't use it now so ...
#
#	text :first_name
#	text :middle_name
#	text :maiden_name
#	text :last_name
#	text :mother_first_name
#	text :mother_middle_name
#	text :mother_maiden_name
#	text :mother_last_name
#	text :father_first_name
#	text :father_middle_name
#	text :father_last_name
#	text :guardian_first_name
#	text :guardian_middle_name
#	text :guardian_last_name
#	text :studyid
#	text :icf_master_id
#	text :childid
#	text :patid
#	text :hospital_no
#	text :state_id_no
#	text :state_registrar_no
#	text :local_registrar_no
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


end	#	class_eval
end	#	included
end	#	StudySubjectSunspot
__END__

Dynamic Fields

I wouldn’t be surprised if I’m the only person who ever uses this feature of Sunspot, but just in case, let’s look at a real-world example. Let’s say part of my data model uses free-form key-value pairs, which use a constrained (but user-definable) set of keys and free-form values. I’ll call my model KeyValuePairs.

The trick I would like to pull here is that I would like to treat each key as a separate field in search, so that I can constrain, order, facet, etc. on the values for one key without them being affected by other keys. Since the keys are user-defined, I can’t just set up normal fields at build time; they need to be defined at index time. Enter Sunspot’s dynamic fields (we’ll use Sunspot::Rails’s wrapper API here):

class Business < ActiveRecord::Base
  has_many :key_value_pairs


  searchable do
    dynamic_string :key_value_pairs do
      key_value_pairs.inject({}) do |hash, pair|
        hash.merge(pair.key.to_sym => pair.value)
      end
    end
  end
end

This sets up a dynamic field which is populated using the given block. What’s important there is that the field is populated using a hash - the keys of the hash become individual dynamic fields, and the values populate those fields in the index. The “base name” of the field is key_value_pairs, which is used to namespace the dynamic names that come out of the hash.

Working with dynamic fields is a lot like working with regular ones, except in the query, calls are wrapped in a dynamic block:

Business.search do
  dynamic :key_value_pairs do
    with(:cuisine, 'Sushi')
    facet(:atmosphere)
  end
end

Naturally, those field names (:cuisine, :atmosphere) wouldn’t be hard-coded in a real application, since they would not be known at build time.




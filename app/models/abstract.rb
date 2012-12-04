#	Abstract model
class Abstract < ActiveRecord::Base

	belongs_to :study_subject	#, :counter_cache => true

	with_options :class_name => 'User', :primary_key => 'uid' do |u|
		u.belongs_to :entry_1_by, :foreign_key => 'entry_1_by_uid'
		u.belongs_to :entry_2_by, :foreign_key => 'entry_2_by_uid'
		u.belongs_to :merged_by,  :foreign_key => 'merged_by_uid'
	end

	validations_from_yaml_file

	attr_protected :study_subject_id, :study_subject
	attr_protected :entry_1_by_uid
	attr_protected :entry_2_by_uid
	attr_protected :merged_by_uid

	attr_accessor :current_user
	attr_accessor :weight_units, :height_units
	attr_accessor :merging	#	flag to be used to skip 2 abstract limitation

	#	The :on => :create doesn't seem to work as described
	#	validate_on_create is technically deprecated, but still works
#	NOTE does this actually work???
#	validate_on_create :subject_has_less_than_three_abstracts	#, :on => :create
#	validate_on_create :subject_has_no_merged_abstract	#, :on => :create
	validate :subject_has_less_than_three_abstracts, :on => :create
	validate :subject_has_no_merged_abstract, :on => :create

	before_create :set_user
	after_create  :delete_unmerged
	before_save   :convert_height_to_cm
	before_save   :convert_weight_to_kg
	before_save   :set_days_since_fields

	def self.fields
		#	db: db field name
		#	human: humanized field
#			File.join(File.dirname(__FILE__),'../../config/abstract_fields.yml')
		@@fields ||= YAML::load( ERB.new( IO.read(
			File.join(Rails.root,'config/abstract_fields.yml')
		)).result)
#
#	Assuming that eventually there will be a preferred order,
#	we'll probably need to use this config file.
#
#	will need to add computed fields also, but this works too ...
#	could then remove this config file
#		@@fields ||= Abstract.comparable_attribute_names.collect{|f|
#			{:db => f, :human => Abstract.human_attribute_name(f) }
#		}
	end

	def fields
		Abstract.fields
	end

	def self.db_fields
#		@db_fields ||= fields.collect{|f|f[:db]}
		Abstract.fields.collect{|f|f[:db]}
	end

	def db_fields
		Abstract.db_fields
	end

#	#	this multi-line array probably won't test 100% if used
#	#	may have to create a config file for this too!
#	def self.incomparable_attribute_names
#		@@incomparable_attribute_names ||= [
#			'id','study_subject_id','created_at','updated_at','entry_1_by_uid',
#			'entry_2_by_uid','merged_by_uid',
#			"response_day_14_days_since_diagnosis", 
#			"response_day_14_days_since_treatment_began", 
#			"response_day_28_days_since_diagnosis", 
#			"response_day_28_days_since_treatment_began", 
#			"response_day_7_days_since_diagnosis", 
#			"response_day_7_days_since_treatment_began"]
#	end
#
#	def self.comparable_attribute_names
#		@@comparable_attribute_names ||= (
#			Abstract.attribute_names - Abstract.incomparable_attribute_names )
#	end

	#	db_fields need defined first though
#	attr_accessible *(Abstract.db_fields + [:current_user,:weight_units,:height_units,:merging])
#	attr_accessible *Abstract.db_fields

	def comparable_attributes
#		HWIA[attributes.select {|k,v| 
#			!Abstract.incomparable_attribute_names.include?(k)}]
		HWIA[attributes.select {|k,v| db_fields.include?(k)}]
	end

	def is_the_same_as?(another_abstract)
		self.diff(another_abstract).blank?
	end

	def diff(another_abstract)
		a1 = self.comparable_attributes
		a2 = Abstract.find(another_abstract).comparable_attributes
		HWIA[a1.select{|k,v| a2[k] != v unless( a2[k].blank? && v.blank? ) }]
	end

	def self.sections
		#	:label: Cytogenetics
		#	:controller: CytogeneticsController
		#	:edit:  :edit_abstract_cytogenetic_path
		#	:show:  :abstract_cytogenetic_path
		@@sections ||= YAML::load(ERB.new( IO.read(
			File.join(File.dirname(__FILE__),'../../config/abstract_sections.yml')
		)).result)
	end

	def merged?
		!merged_by_uid.blank?
	end

#	scope :merged,   where('merged_by_uid IS NOT NULL')
	scope :merged,   
		where(self.arel_table[:merged_by_uid].not_eq(nil) )
#	scope :unmerged, where('merged_by_uid IS NULL')
	scope :unmerged, where('merged_by_uid' => nil)

protected

	def set_days_since_fields
		#	must explicitly convert these DateTimes to Date so that the
		#	difference is in days and not seconds
		#	I really only need to do this if something changes,
		#	but for now, just do it and make sure that
		#	it is tested.  Optimize and refactor later.
		unless diagnosed_on.nil?
			self.response_day_7_days_since_diagnosis = (
				response_report_on_day_7.to_date - diagnosed_on.to_date 
				) unless response_report_on_day_7.nil?
			self.response_day_14_days_since_diagnosis = (
				response_report_on_day_14.to_date - diagnosed_on.to_date 
				) unless response_report_on_day_14.nil?
			self.response_day_28_days_since_diagnosis = (
				response_report_on_day_28.to_date - diagnosed_on.to_date 
				) unless response_report_on_day_28.nil?
		end
		unless treatment_began_on.nil?
			self.response_day_7_days_since_treatment_began = (
				response_report_on_day_7.to_date - treatment_began_on.to_date 
				) unless response_report_on_day_7.nil?
			self.response_day_14_days_since_treatment_began = (
				response_report_on_day_14.to_date - treatment_began_on.to_date 
				) unless response_report_on_day_14.nil?
			self.response_day_28_days_since_treatment_began = (
				response_report_on_day_28.to_date - treatment_began_on.to_date 
				) unless response_report_on_day_28.nil?
		end
	end

	def convert_height_to_cm
		if( !height_units.nil? && height_units.match(/in/i) )
			self.height_units = nil
			self.height_at_diagnosis *= 2.54
		end
	end

	def convert_weight_to_kg
		if( !weight_units.nil? && weight_units.match(/lb/i) )
			self.weight_units = nil
			self.weight_at_diagnosis /= 2.2046
		end
	end

	#	Set user if given
	def set_user
		if study_subject
			#	because it is possible to create the first, then the second
			#	and then delete the first, and create another, first and
			#	second kinda lose their meaning until the merge, so set them
			#	both as the same until the merge
			case study_subject.abstracts.count
				when 0 
					self.entry_1_by_uid = current_user.try(:uid)||0
					self.entry_2_by_uid = current_user.try(:uid)||0
				when 1 
					self.entry_1_by_uid = current_user.try(:uid)||0
					self.entry_2_by_uid = current_user.try(:uid)||0
				when 2
					abs = study_subject.abstracts
					#	compact just in case a nil crept in
					self.entry_1_by_uid = [abs[0].entry_1_by_uid,abs[0].entry_2_by_uid].compact.first
					self.entry_2_by_uid = [abs[1].entry_1_by_uid,abs[1].entry_2_by_uid].compact.first
					self.merged_by_uid  = current_user.try(:uid)||0
			end
		end
	end

	def delete_unmerged
		if study_subject and !merged_by_uid.blank?
			#	use delete and not destroy to preserve the abstracts_count
#	gonna stop using abstracts_count so really won't matter
			study_subject.abstracts.unmerged.each{|a|a.delete}
		end
	end

	def subject_has_less_than_three_abstracts
		#	because this abstract hasn't been created yet, we're comparing to 2, not 3
		if study_subject and study_subject.abstracts.count >= 2 and !merging
			errors.add(:study_subject_id,"Study Subject can only have 2 unmerged abstracts.")
		end
	end

	def subject_has_no_merged_abstract
		if study_subject and !study_subject.abstracts.merged.empty?
			errors.add(:study_subject_id,"Study Subject already has a merged abstract." )
		end
	end

end

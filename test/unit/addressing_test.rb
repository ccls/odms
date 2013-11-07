require 'test_helper'

class AddressingTest < ActiveSupport::TestCase

	assert_should_create_default_object
	assert_should_protect(:study_subject_id, :study_subject)

	attributes = %w( current_address address_at_diagnosis 
		line_1 line_2 unit city state zip county country external_address_id )
	required   = %w( line_1 city state zip )
	unique     = %w( external_address_id )
	assert_should_require( required )
	assert_should_not_require( attributes - required )
#	assert_should_require_unique( unique )
	assert_should_not_require_unique( attributes - unique )
	assert_should_not_protect( attributes )

	assert_should_initially_belong_to( :study_subject )
	assert_should_require_attribute_length( :notes,
			:maximum => 65000 )

	#	Someone always has to think that they are special!
	assert_should_accept_only_good_values( :current_address,
		{ :good_values => ( YNDK.valid_values ), 
			:bad_values  => 12345 })

	assert_should_accept_only_good_values( :address_at_diagnosis,
		{ :good_values => ( YNDK.valid_values + [nil] ), 
			:bad_values  => 12345 })

	assert_should_accept_only_good_values( :data_source,
		{ :good_values => Addressing.valid_data_sources, 
			:bad_values  => "I'm not valid" })

	assert_should_require_attribute_length( 
		:zip, :maximum => 10 )
	assert_should_require_attribute_length( 
		:line_1, :line_2, :unit, :city, :state, :maximum => 250 )

#	assert_should_have_many(:interviews)	#	address did

	assert_should_accept_only_good_values( :address_type,
		{ :good_values => Addressing.valid_address_types, 
			:bad_values  => "I'm not valid" })


	test "addressing factory should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:addressing)
		}
	end

	test "addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = FactoryGirl.create(:addressing)
			assert_not_nil addressing.study_subject
		}
	end

	test "mailing_addressing factory should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:mailing_addressing)
			assert_equal addressing.current_address, YNDK[:no]
		}
	end

	test "mailing_addressing factory should create mailing address" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:mailing_addressing)
			assert_equal addressing.address_type,
				'Mailing'
		}
	end

	test "mailing_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = FactoryGirl.create(:mailing_addressing)
		}
	end

	test "current_mailing_addressing factory should create current addressing" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:current_mailing_addressing)
			assert_equal addressing.current_address, YNDK[:yes]
		}
	end

	test "current_mailing_addressing factory should create mailing address" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:current_mailing_addressing)
			assert_equal addressing.address_type,
				'Mailing'
		}
	end

	test "current_mailing_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = FactoryGirl.create(:current_mailing_addressing)
		}
	end

	test "residence_addressing factory should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:residence_addressing)
			assert_equal addressing.current_address, YNDK[:no]
		}
	end

	test "residence_addressing factory should create residence address" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:residence_addressing)
			assert_equal addressing.address_type,
				'Residence'
		}
	end

	test "residence_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = FactoryGirl.create(:residence_addressing)
		}
	end

	test "current_residence_addressing factory should create current addressing" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:current_residence_addressing)
			assert_equal addressing.current_address, YNDK[:yes]
		}
	end

	test "current_residence_addressing factory should create residence address" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:current_residence_addressing)
			assert_equal addressing.address_type,
				'Residence'
		}
	end

	test "current_residence_addressing factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			addressing = FactoryGirl.create(:current_residence_addressing)
		}
	end

	test "current_address should default to 1" do
		addressing = Addressing.new
		assert_equal 1, addressing.current_address
	end

	test "should require data_source" do
		addressing = Addressing.new( :data_source => nil)
		assert !addressing.valid?
		assert  addressing.errors.matching?(:data_source,"can't be blank")
	end

	test "should require other_data_source if data_source is other" do
		#	The factory will create the associations regardless
		#	so an Address and StudySubject gets created regardless
		addressing = Addressing.new( :data_source => 'Other Source' )
		assert !addressing.valid?
		assert addressing.errors.matching?(:other_data_source, "can't be blank")
	end

	test "should NOT require other_data_source if data_source is not other" do
		addressing = Addressing.new( :data_source => 'RAF (CCLS Rapid Ascertainment Form)')
		addressing.valid?
		assert !addressing.errors.matching?(:other_data_source, "can't be blank")
	end

	test "current scope should only return current addressings" do
		y = create_addressing(:current_address => YNDK[:yes])
		n = create_addressing(:current_address => YNDK[:no])
		d = create_addressing(:current_address => YNDK[:dk])
		addressings = Addressing.current
		assert_equal 1, addressings.length
		assert  addressings.include?( y )
		assert !addressings.include?( n )
		assert !addressings.include?( d )
	end

	test "historic scope should only return historic addressings" do
		y = create_addressing(:current_address => YNDK[:yes])
		n = create_addressing(:current_address => YNDK[:no])
		d = create_addressing(:current_address => YNDK[:dk])
		addressings = Addressing.historic
		assert_equal 2, addressings.length
		assert !addressings.include?( y )
		assert  addressings.include?( n )
		assert  addressings.include?( d )
	end

	test "mailing scope should only return mailing addressings" do
		create_addressing
		a = create_mailing_addressing
		create_residence_addressing
		addressings = Addressing.mailing
		assert_equal 1, addressings.length
		assert_equal a, addressings.first
	end

#	test "should make study_subject ineligible "<<
#			"on create if state NOT 'CA' and address is ONLY residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',1) {
#		assert_difference('Addressing.count',1) {
#			create_az_addressing(study_subject)
#		} }
#		assert_study_subject_is_not_eligible(study_subject)
#		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#		assert_equal   hxe.ineligible_reason,
#			IneligibleReason['newnonCA']
#	end
#
#	test "should make study_subject ineligible "<<
#			"on create if state NOT 'CA' and address is ANOTHER residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',1) {
#		assert_difference("Addressing.count", 2 ) {
#			ca_addressing = create_ca_addressing(study_subject)
#			az_addressing = create_az_addressing(study_subject)
#		} }
#		assert_study_subject_is_not_eligible(study_subject)
#		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
#		assert_equal   hxe.ineligible_reason,
#			IneligibleReason['moved']
#	end
#
#	test "should NOT make study_subject ineligible "<<
#			"on create if OET is missing" do
#		OperationalEventType['ineligible'].destroy
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',0) {
#		assert_difference("Addressing.count", 1 ) {
#			create_ca_addressing(study_subject)
#			assert_raise(ActiveRecord::RecordNotSaved){
#				addressing = create_az_addressing(study_subject)
#		} } }
#		assert_study_subject_is_eligible(study_subject)
#	end
#
#	test "should NOT make study_subject ineligible "<<
#			"on create if state NOT 'CA' and address is NOT residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',0) {
#		assert_difference("Addressing.count", 1 ) {
#			addressing = create_az_addressing(study_subject,
#				:address => { :address_type => 'Mailing' })
#		} }
#		assert_study_subject_is_eligible(study_subject)
#	end
#
#	test "should NOT make study_subject ineligible "<<
#			"on create if state 'CA' and address is residence" do
#		study_subject = create_eligible_hx_study_subject
#		assert_difference('OperationalEvent.count',0) {
#		assert_difference("Addressing.count", 1 ) {
#			addressing = create_ca_addressing(study_subject)
#		} }
#		assert_study_subject_is_eligible(study_subject)
#	end


#	'1' and '0' are the default values for a checkbox.
#	I probably should add a condition to this event that
#	the address_type be 'Residence', but I've left that to the view.
#			addressing = FactoryGirl.create(:current_residence_addressing)

	test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
			" if not residence address" do
		addressing = FactoryGirl.create(:current_mailing_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
			" if was not current address" do
		addressing = FactoryGirl.create(:residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should add 'subject_moved' event to subject if subject_moved is '1'" do
		addressing = FactoryGirl.create(:current_residence_addressing)
		assert_difference('OperationalEvent.count',1) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is '0'" do
		addressing = FactoryGirl.create(:current_residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => '0')
		}
	end

	test "should add 'subject_moved' event to subject if subject_moved is 'true'" do
		addressing = FactoryGirl.create(:current_residence_addressing)
		assert_difference('OperationalEvent.count',1) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => 'true')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is 'false'" do
		addressing = FactoryGirl.create(:current_residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => 'false')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is nil" do
		addressing = FactoryGirl.create(:current_residence_addressing)
		assert_difference('OperationalEvent.count',0) {
			addressing.update_attributes(
				:current_address => '2',
				:subject_moved => nil)
		}
	end

	test "should flag study subject for reindexed on create" do
		addressing = FactoryGirl.create(:addressing).reload
		assert_not_nil addressing.study_subject
		assert addressing.study_subject.needs_reindexed
	end

	test "should flag study subject for reindexed on update" do
		addressing = FactoryGirl.create(:addressing).reload
		assert_not_nil addressing.study_subject
		assert  addressing.study_subject.needs_reindexed
		addressing.study_subject.update_attribute(:needs_reindexed, false)
		assert !addressing.study_subject.needs_reindexed
		addressing.update_attributes(:other_data_source => "something to make it dirty")
		assert  addressing.study_subject.needs_reindexed
	end



	#	external_address_id isn't required so don't use class level test
	#	would have to modify class level test to try to put something
	#	in the field, but would have to determine datatype and ......
	test "should require unique external_address_id" do
		FactoryGirl.create(:addressing,:external_address_id => 123456789)
		addressing = Addressing.new(:external_address_id => 123456789)
		assert !addressing.valid?
		assert addressing.errors.matching?(:external_address_id,
			'has already been taken')
	end








	test "address factory should create address" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:addressing)
			assert_match /Box \d*/, addressing.line_1
			assert_equal "Berkeley", addressing.city
			assert_equal "CA", addressing.state
			assert_equal "12345", addressing.zip
		}
	end

	test "mailing_address should create address" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:mailing_addressing)
		}
	end

	test "residence_addressing should create addressing" do
		assert_difference('Addressing.count',1) {
			addressing = FactoryGirl.create(:residence_addressing)
		}
	end

	test "should require address_type" do
		addressing = Addressing.new( :address_type => nil)
		assert !addressing.valid?
		assert  addressing.errors.matching?(:address_type, "can't be blank")
	end

	test "should require 5 or 9 digit zip" do
		%w( asdf 1234 123456 1234Q ).each do |bad_zip|
			addressing = Addressing.new( :zip => bad_zip )
			assert !addressing.valid?
			assert addressing.errors.include?(:zip)
			assert addressing.errors.matching?(:zip,
				'Zip should be 12345, 123451234 or 12345-1234'), 
					addressing.errors.full_messages.to_sentence
		end
		%w( 12345 12345-6789 123456789 ).each do |good_zip|
			addressing = Addressing.new( :zip => good_zip )
			addressing.valid?
			assert !addressing.errors.include?(:zip)
			assert addressing.zip =~ /\A\d{5}(-)?(\d{4})?\z/
		end
	end

	test "should format 9 digit zip" do
		assert_difference( "Addressing.count", 1 ) do
			addressing = create_addressing( :zip => '123456789' )
#			addressing = Addressing.new( :zip => '123456789' )
#			addressing.valid?
#	the formating is currently in a before save, so have to save it.
			assert !addressing.errors.include?(:zip)
			assert addressing.zip =~ /\A\d{5}(-)?(\d{4})?\z/
			assert_equal '12345-6789', addressing.zip
		end
	end

	test "should return city state and zip with csz" do
		addressing = Addressing.new(
			:city  => 'City',
			:state => 'CA',
			:zip   => '12345')
		assert_equal "City, CA 12345", addressing.csz
	end

	test "should return street with just line_1 if line_2 blank" do
		addressing = Addressing.new( :line_1   => 'I am line_1')
		assert_equal "I am line_1", addressing.street
	end

	test "should return street with join of line_1 and line_2" do
		addressing = Addressing.new( 
			:line_1   => 'I am line_1',
			:line_2   => 'I am line_2')
		assert_equal "I am line_1, I am line_2", addressing.street
	end

	#	Note that there are probably legitimate address line 1's 
	#	that will match the p.*o.*box regex.
	test "should require non-residence address type with pobox in line" do
		["P.O. Box 123","PO Box 123","P O Box 123","Post Office Box 123"].each do |pobox|
			addressing = Addressing.new( 
				:line_1 => pobox,
				:address_type => 'Residence'
			)
			assert !addressing.valid?
			assert addressing.errors.include?(:address_type)
		end
	end

protected

	def create_addressing_with_address(study_subject,options={})
		create_addressing({
			:study_subject => study_subject,
#	doesn't work in rcov for some reason
#			:address => nil,	#	block address_attributes
#			:address_id => nil,	#	block address_attributes
#			:address_attributes => FactoryGirl.attributes_for(:address,{
#				:address_type => 'Residence'
#			}.merge(options[:address]||{}))
		}.merge(options[:addressing]||{}))
	end

	def create_ca_addressing(study_subject,options={})
		create_addressing_with_address(study_subject,{:state => 'CA'}.merge(options))
	end

	def create_az_addressing(study_subject,options={})
		create_addressing_with_address(study_subject,{:state => 'AZ'}.merge(options))
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_addressing

end

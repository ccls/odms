require 'test_helper'

class AddressTest < ActiveSupport::TestCase

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
		{ :good_values => Address.const_get( :VALID_DATA_SOURCES ), 
			:bad_values  => "I'm not valid" })

	assert_should_require_attribute_length( 
		:zip, :maximum => 10 )
	assert_should_require_attribute_length( 
		:line_1, :line_2, :unit, :city, :state, :maximum => 250 )

#	assert_should_have_many(:interviews)	#	address did

	assert_should_accept_only_good_values( :address_type,
		{ :good_values => Address.const_get( :VALID_ADDRESS_TYPES ), 
			:bad_values  => "I'm not valid" })


#	test "address factory should create address" do
#		assert_difference('Address.count',1) {
#			address = FactoryGirl.create(:address)
#		}
#	end

	test "address factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			address = FactoryGirl.create(:address)
			assert_not_nil address.study_subject
		}
	end

	test "mailing_address factory should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:mailing_address)
			assert_equal address.current_address, YNDK[:no]
		}
	end

	test "mailing_address factory should create mailing address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:mailing_address)
			assert_equal address.address_type,
				'Mailing'
		}
	end

	test "mailing_address factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			address = FactoryGirl.create(:mailing_address)
		}
	end

	test "current_mailing_address factory should create current address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:current_mailing_address)
			assert_equal address.current_address, YNDK[:yes]
		}
	end

	test "current_mailing_address factory should create mailing address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:current_mailing_address)
			assert_equal address.address_type,
				'Mailing'
		}
	end

	test "current_mailing_address factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			address = FactoryGirl.create(:current_mailing_address)
		}
	end

	test "residence_address factory should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:residence_address)
			assert_equal address.current_address, YNDK[:no]
		}
	end

	test "residence_address factory should create residence address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:residence_address)
			assert_equal address.address_type,
				'Residence'
		}
	end

	test "residence_address factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			address = FactoryGirl.create(:residence_address)
		}
	end

	test "current_residence_address factory should create current address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:current_residence_address)
			assert_equal address.current_address, YNDK[:yes]
		}
	end

	test "current_residence_address factory should create residence address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:current_residence_address)
			assert_equal address.address_type,
				'Residence'
		}
	end

	test "current_residence_address factory should create study subject" do
		assert_difference('StudySubject.count',1) {
			address = FactoryGirl.create(:current_residence_address)
		}
	end

	test "current_address should default to 1" do
		address = Address.new
		assert_equal 1, address.current_address
	end

	test "should require data_source" do
		address = Address.new( :data_source => nil)
		assert !address.valid?
		assert  address.errors.matching?(:data_source,"can't be blank")
	end

	test "should require other_data_source if data_source is other" do
		#	The factory will create the associations regardless
		#	so an Address and StudySubject gets created regardless
		address = Address.new( :data_source => 'Other Source' )
		assert !address.valid?
		assert address.errors.matching?(:other_data_source, "can't be blank")
	end

	test "should NOT require other_data_source if data_source is not other" do
		address = Address.new( :data_source => 'RAF (CCLS Rapid Ascertainment Form)')
		address.valid?
		assert !address.errors.matching?(:other_data_source, "can't be blank")
	end

	test "current scope should only return current addresses" do
		y = create_address(:current_address => YNDK[:yes])
		n = create_address(:current_address => YNDK[:no])
		d = create_address(:current_address => YNDK[:dk])
		addresses = Address.current
		assert_equal 1, addresses.length
		assert  addresses.include?( y )
		assert !addresses.include?( n )
		assert !addresses.include?( d )
	end

	test "historic scope should only return historic addresses" do
		y = create_address(:current_address => YNDK[:yes])
		n = create_address(:current_address => YNDK[:no])
		d = create_address(:current_address => YNDK[:dk])
		addresses = Address.historic
		assert_equal 2, addresses.length
		assert !addresses.include?( y )
		assert  addresses.include?( n )
		assert  addresses.include?( d )
	end

	test "mailing scope should only return mailing addresses" do
		create_address
		a = create_mailing_address
		create_residence_address
		addresses = Address.mailing
		assert_equal 1, addresses.length
		assert_equal a, addresses.first
	end

#	'1' and '0' are the default values for a checkbox.
#	I probably should add a condition to this event that
#	the address_type be 'Residence', but I've left that to the view.
#			address = FactoryGirl.create(:current_residence_address)

	test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
			" if not residence address" do
		address = FactoryGirl.create(:current_mailing_address)
		assert_difference('OperationalEvent.count',0) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should NOT add 'subject_moved' event to subject if subject_moved is '1'" <<
			" if was not current address" do
		address = FactoryGirl.create(:residence_address)
		assert_difference('OperationalEvent.count',0) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should add 'subject_moved' event to subject if subject_moved is '1'" do
		address = FactoryGirl.create(:current_residence_address)
		assert_difference('OperationalEvent.count',1) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => '1')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is '0'" do
		address = FactoryGirl.create(:current_residence_address)
		assert_difference('OperationalEvent.count',0) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => '0')
		}
	end

	test "should add 'subject_moved' event to subject if subject_moved is 'true'" do
		address = FactoryGirl.create(:current_residence_address)
		assert_difference('OperationalEvent.count',1) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => 'true')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is 'false'" do
		address = FactoryGirl.create(:current_residence_address)
		assert_difference('OperationalEvent.count',0) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => 'false')
		}
	end

	test "should not add 'subject_moved' event to subject if subject_moved is nil" do
		address = FactoryGirl.create(:current_residence_address)
		assert_difference('OperationalEvent.count',0) {
			address.update_attributes(
				:current_address => '2',
				:subject_moved => nil)
		}
	end

	test "should flag study subject for reindexed on create" do
		address = FactoryGirl.create(:address).reload
		assert_not_nil address.study_subject
		assert address.study_subject.needs_reindexed
	end

	test "should flag study subject for reindexed on update" do
		address = FactoryGirl.create(:address).reload
		assert_not_nil address.study_subject
		study_subject = address.study_subject
		assert  study_subject.needs_reindexed
		study_subject.update_column(:needs_reindexed, false)
		assert !study_subject.needs_reindexed
		address.update_attributes(:other_data_source => "something to make it dirty")
		assert  study_subject.needs_reindexed
	end



	#	external_address_id isn't required so don't use class level test
	#	would have to modify class level test to try to put something
	#	in the field, but would have to determine datatype and ......
	test "should require unique external_address_id" do
		FactoryGirl.create(:address,:external_address_id => 123456789)
		address = Address.new(:external_address_id => 123456789)
		assert !address.valid?
		assert address.errors.matching?(:external_address_id,
			'has already been taken')
	end








	test "address factory should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:address)
			assert_match /Box \d*/, address.line_1
			assert_equal "Berkeley", address.city
			assert_equal "CA", address.state
			assert_equal "12345", address.zip
		}
	end

	test "mailing_address should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:mailing_address)
		}
	end

	test "residence_address should create address" do
		assert_difference('Address.count',1) {
			address = FactoryGirl.create(:residence_address)
		}
	end

	test "should require address_type" do
		address = Address.new( :address_type => nil)
		assert !address.valid?
		assert  address.errors.matching?(:address_type, "can't be blank")
	end

	test "should require 5 or 9 digit zip" do
		%w( asdf 1234 123456 1234Q ).each do |bad_zip|
			address = Address.new( :zip => bad_zip )
			assert !address.valid?
			assert address.errors.include?(:zip)
			assert address.errors.matching?(:zip,
				'Zip should be 12345, 123451234 or 12345-1234'), 
					address.errors.full_messages.to_sentence
		end
		%w( 12345 12345-6789 123456789 ).each do |good_zip|
			address = Address.new( :zip => good_zip )
			address.valid?
			assert !address.errors.include?(:zip)
			assert address.zip =~ /\A\d{5}(-)?(\d{4})?\z/
		end
	end

	test "should format 9 digit zip" do
		assert_difference( "Address.count", 1 ) do
			address = create_address( :zip => '123456789' )
#			address = Address.new( :zip => '123456789' )
#			address.valid?
#	the formating is currently in a before save, so have to save it.
			assert !address.errors.include?(:zip)
			assert address.zip =~ /\A\d{5}(-)?(\d{4})?\z/
			assert_equal '12345-6789', address.zip
		end
	end

	test "should return streets,unit,city,state and zip with full" do
		address = Address.new(
			:line_1 => '123 Main',
			:line_2 => 'Suite 456',
			:unit  => '789',
			:city  => 'City',
			:state => 'CA',
			:zip   => '12345')
#
#	NOTE does NOT include the unit?
#
		assert_equal "123 Main, Suite 456, City, CA 12345", address.full
	end

	test "should return city state and zip with csz" do
		address = Address.new(
			:city  => 'City',
			:state => 'CA',
			:zip   => '12345')
		assert_equal "City, CA 12345", address.csz
	end

	test "should return street with just line_1 if line_2 blank" do
		address = Address.new( :line_1   => 'I am line_1')
		assert_equal "I am line_1", address.street
	end

	test "should return street with join of line_1 and line_2" do
		address = Address.new( 
			:line_1   => 'I am line_1',
			:line_2   => 'I am line_2')
		assert_equal "I am line_1, I am line_2", address.street
	end

	#	Note that there are probably legitimate address line 1's 
	#	that will match the p.*o.*box regex.
	test "should require non-residence address type with pobox in line" do
		["P.O. Box 123","PO Box 123","P O Box 123","Post Office Box 123"].each do |pobox|
			address = Address.new( 
				:line_1 => pobox,
				:address_type => 'Residence'
			)
			assert !address.valid?
			assert address.errors.include?(:address_type)
		end
	end

protected

	def create_address_with_address(study_subject,options={})
		create_address({
			:study_subject => study_subject,
#	doesn't work in rcov for some reason
#			:address => nil,	#	block address_attributes
#			:address_id => nil,	#	block address_attributes
#			:address_attributes => FactoryGirl.attributes_for(:address,{
#				:address_type => 'Residence'
#			}.merge(options[:address]||{}))
		}.merge(options[:address]||{}))
	end

	def create_ca_address(study_subject,options={})
		create_address_with_address(study_subject,{:state => 'CA'}.merge(options))
	end

	def create_az_address(study_subject,options={})
		create_address_with_address(study_subject,{:state => 'AZ'}.merge(options))
	end

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_address

end

module CclsAssertions

	def self.included(base)
		base.extend(ClassMethods)

		#	basically to include the model_name method
		base.extend ActiveModel::Naming
	end

	def assert_subject_is_eligible(study_subject)
		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
		assert_not_nil hxe
		assert_nil     hxe.ineligible_reason_id
		assert_equal   hxe.is_eligible, YNDK[:yes]
	end
	alias_method :assert_study_subject_is_eligible, :assert_subject_is_eligible

	def assert_subject_is_not_eligible(study_subject)
		hxe = study_subject.enrollments.find_by_project_id(Project['HomeExposures'].id)
		assert_not_nil hxe
		assert_not_nil hxe.ineligible_reason_id
		assert_equal   hxe.is_eligible, YNDK[:no]
	end
	alias_method :assert_study_subject_is_not_eligible, :assert_subject_is_not_eligible

	module ClassMethods

		def assert_should_create_default_object
			#	It appears that model_name is a defined class method already in ...
			#	activesupport-####/lib/active_support/core_ext/module/model_naming.rb
			test "should create default #{model_name.sub(/Test$/,'').underscore}" do
				assert_difference( "#{model_name}.count", 1 ) do
					object = create_object
					assert !object.new_record?, 
						"#{object.errors.full_messages.to_sentence}"
				end
			end
		end

		def assert_should_behave_like_a_hash(*args)
			options = {
				:key => :key,
				:value => :description
			}
			options.update(args.extract_options!)

			assert_should_require_attribute( options[:key], options[:value] )
			assert_should_require_unique_attribute( options[:key], options[:value] )
			assert_should_require_attribute_length( options[:key], options[:value],
				:maximum => 250 )

			test "should find by key with ['string']" do
				object = create_object
				assert object.is_a?(model_name.constantize)
				found = (model_name.constantize)[object.key.to_s]
				assert found.is_a?(model_name.constantize)
				assert_equal object, found
			end

			test "should find by key with [:symbol]" do
				object = create_object
				assert object.is_a?(model_name.constantize)
				found = (model_name.constantize)[object.key.to_sym]
				assert found.is_a?(model_name.constantize)
				assert_equal object, found
			end

		end	#	def assert_should_behave_like_a_hash(*args)

		def assert_should_accept_only_good_values(*attributes)
			options = {
				:good_values => [],
				:bad_values  => []
			}
			options.update(attributes.extract_options!)

			attributes.flatten.each do |field|

				[options[:bad_values]].flatten.each do |value|

#	could be a naming problem if both nil and blank are passed

					test "should NOT allow #{value||'nil'} for #{field}" do
						object = model_name.constantize.new(field => value)
						assert_equal object.send(field), value
						object.valid?
						assert object.errors.on_attr_and_type?(field,:inclusion)
					end

				end

				[options[:good_values]].flatten.each do |value|
		
#	could be a naming problem if both nil and blank are passed

					test "should allow #{value||'nil'} for #{field}" do
						object = model_name.constantize.new(field => value)
						assert_equal object.send(field), value
						object.valid?
						assert !object.errors.on(field)
					end

				end
		
			end	#	attributes.flatten.each do |field|

		end	#	def assert_should_accept_only_good_values(*attributes)

	end	#	module ClassMethods

end
ActiveSupport::TestCase.send(:include,CclsAssertions)

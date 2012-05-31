module FactoryTestHelper

	#	
	#	If these aren't defined, autotest can hang indefinitely
	#	and you won't know why.
	#
	#	I think that there is a way to tell Factory Girl to use
	#	"save" instead of "save!" which would have removed the
	#	need for this MOSTLY.  There are a few exceptions.
	FactoryGirl.factories.collect(&:name).each do |object|
		#
		#	define a method that is commonly used in these class level tests
		#	I'd actually prefer to not do this, but is very helpful.
		#
		define_method "create_#{object}" do |*args|
			options = args.extract_options!
			new_object = Factory.build(object,options)
			new_object.save
			new_object
		end
	end

	def create_home_exposure_with_study_subject(options={})
		study_subject = project = nil
		unless options[:patient].nil?
			options[:study_subject] ||= {}
			options[:study_subject][:subject_type] = SubjectType['Case']
		end
		assert_difference('Enrollment.count',1) {	#	ccls
		assert_difference('StudySubject.count',1) {
			study_subject    = Factory(:study_subject,options[:study_subject]||{})
		} }
		project = Project['HomeExposures']
		assert_not_nil project
		assert_difference('StudySubject.count',0) {
		assert_difference('Enrollment.count',1) {
			Factory(:enrollment, (options[:enrollment]||{}).merge(
				:study_subject => study_subject, :project => project ))
		} }
		unless options[:patient].nil?
			assert_difference('StudySubject.count',0) {
			assert_difference('Patient.count',1) {
				Factory(:patient, :study_subject => study_subject )
			} }
		end
		study_subject
	end
	alias_method :create_hx_study_subject, 
		:create_home_exposure_with_study_subject

end
ActiveSupport::TestCase.send(:include, FactoryTestHelper)

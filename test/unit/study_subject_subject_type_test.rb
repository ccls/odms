require 'test_helper'

class StudySubjectSubjectTypeTest < ActiveSupport::TestCase

	assert_should_protect( :subject_type_id, :model => 'StudySubject' )
	assert_should_initially_belong_to( :subject_type, :model => 'StudySubject' )

	test "should require subject_type" do
#	protected so block assignment needed
		study_subject = StudySubject.new{|s|s.subject_type = nil}
		assert !study_subject.valid?
		assert !study_subject.errors.include?(:subject_type)
		assert  study_subject.errors.matching?(:subject_type_id,"can't be blank")
	end

	test "should require valid subject_type" do
#	protected so block assignment needed
		study_subject = StudySubject.new{|s|s.subject_type_id = 0}
		assert !study_subject.valid?
		assert !study_subject.errors.include?(:subject_type_id)
		assert  study_subject.errors.matching?(:subject_type,"can't be blank")
	end

	test "should return subject_type description for string" do
		study_subject = create_study_subject
		assert_equal study_subject.subject_type.description,
			"#{study_subject.subject_type}"
	end

	csv = %q(factory,is_case?,is_control?,is_child?,is_twin?,is_mother?,is_father?
case_study_subject,true,false,true,false,false,false
control_study_subject,false,true,true,false,false,false
mother_study_subject,false,false,false,false,true,false
father_study_subject,false,false,false,false,false,true
twin_study_subject,false,false,false,true,false,false
)
	require 'csv'
	(c=CSV.parse(csv,{:headers => true})).each do |line|
		line.headers.each do |header|
			next if header == 'factory'
			test "#{header} should return #{line[header]} for #{line['factory']}" do
				subject = FactoryGirl.create(line['factory'])
				assert_equal subject.send(header).to_s, line[header]
			end
		end
	end

protected

	#	create_object is called from within the common class tests
	alias_method :create_object, :create_study_subject

end

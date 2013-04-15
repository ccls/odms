require 'test_helper'

class IcfMasterTrackerTest < ActiveSupport::TestCase

	test "should update blank interview_completed_on with cati_complete if not blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')
		assert_equal Date.parse('12/31/2012'),study_subject.ccls_enrollment.interview_completed_on
pending
	end

	test "should update different interview_completed_on with cati_complete if not blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		study_subject.ccls_enrollment.update_attribute(:interview_completed_on => '12/31/2000')
		assert_not_nil study_subject.ccls_enrollment.interview_completed_on
		assert_equal Date.parse('12/31/2000'),study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')
		assert_equal Date.parse('12/31/2012'),study_subject.ccls_enrollment.interview_completed_on
pending
	end

	test "should create operational event with cati_complete if not blank and changes interview_completed_on" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')

		#	could be more specific
		oes = study_subject.operational_events
			.where(:operational_event_type_id => OperationalEventType['other'].id)
		assert_equal 1, oes.length
		assert_match /interview_completed_on set to/, oes.first.description

pending
	end

	test "should not create operational event with cati_complete if not blank and same interview_completed_on" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		assert_nil study_subject.ccls_enrollment.interview_completed_on
		study_subject.ccls_enrollment.update_attribute(:interview_completed_on => '12/31/2012')
		assert_not_nil study_subject.ccls_enrollment.interview_completed_on
		assert_equal Date.parse('12/31/2012'),study_subject.ccls_enrollment.interview_completed_on
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST',:cati_complete => '12/31/2012')
		assert_nil study_subject.operational_events
			.where(:operational_event_type_id => OperationalEventType['other'].id)

pending
	end

	test "should do what if cati_complete blank" do
		study_subject = FactoryGirl.create(:study_subject, :icf_master_id => "IDOEXIST")
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IDOEXIST')
pending
	end

	test "should do what if master_id not valid" do
		icf_master_tracker = IcfMasterTracker.new(:master_id => 'IAMBOGUS')
pending
	end

	test "should do what if master_id blank" do
		icf_master_tracker = IcfMasterTracker.new(:master_id => '')
pending
	end

	test "should do what if master_id not given" do
		icf_master_tracker = IcfMasterTracker.new()
pending
	end


#		(f=CSV.open( "ICF_Master_Tracker.csv", 'rb',{
#				:headers => true })).each do |line|
#			puts
#			puts "Processing line :#{f.lineno}:"
#			puts line
#
#			if line['master_id'].blank?
#				#	raise "master_id is blank" 
#				puts "master_id is blank" 
#				next
#			end
#			subjects = StudySubject.where(:icf_master_id => line['master_id'])
#
#			#	Shouldn't be possible as icf_master_id is unique in the db
#			#raise "Multiple case subjects? with icf_master_id:" <<
#			#	"#{line['master_id']}:" if subjects.length > 1
#			unless subjects.length == 1
#				#raise "No subject with icf_master_id: #{line['master_id']}:" 
#				puts "No subject with icf_master_id:#{line['master_id']}:" 
#				next
#			end
#
#			s = subjects.first
#			e = s.enrollments.where(:project_id => Project['ccls'].id).first
#
#			if line['cati_complete'].blank?
#				puts "cati_complete is blank so doing nothing."
#			else
#				puts "cati_complete: #{Time.parse(line['cati_complete']).to_date}"
#				puts "Current interview_completed_on : #{e.interview_completed_on}"
#				e.interview_completed_on = Time.parse(line['cati_complete']).to_date
#				if e.changed?
#					changed << s
#					puts "-- Updated interview_completed_on : #{e.interview_completed_on}"
#					puts "-- Enrollment updated. Creating OE"
#
#					e.save!
#					s.operational_events.create!(
#						:project_id                => Project['ccls'].id,
#						:operational_event_type_id => OperationalEventType['other'].id,
#						:occurred_at               => DateTime.current,
#						:description               => "interview_completed_on set to " <<
#							"cati_complete #{line['cati_complete']} from " <<
#							"ICF Master Tracker file #{mod_time}"
#					)
#
#				else
#					puts "No change so doing nothing."
#				end
#			end	#	if line['cati_complete'].blank?
#		end	#	(f=CSV.open( csv_file.path, 'rb',{


end
__END__

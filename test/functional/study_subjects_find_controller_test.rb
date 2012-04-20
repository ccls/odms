require 'test_helper'

class StudySubjectsFindControllerTest < ActionController::TestCase
	tests StudySubjectsController

	setup :destroy_all_study_subjects
	def destroy_all_study_subjects
#
#	For some reason, some tests don't actually cleanup after themselves
#	and rollback correctly.  Destroy all subjects so counts are correct.
#	Or don't use absolute counts.
#	Or figure out why it does that.
#
		StudySubject.destroy_all
	end

	site_readers.each do |cu|

		test "should get study_subjects find with #{cu} login" do
			3.times{Factory(:study_subject)}
			login_as send(cu)
			get :find
			assert_response :success
			assert_equal 3, assigns(:study_subjects).length
		end

		test "should find study_subjects with #{cu} login and page too high" do
			3.times{Factory(:study_subject)}
			login_as send(cu)
			get :find, :page => 999
			assert_not_nil flash[:warn]
			assert_equal 3, assigns(:study_subjects).count
			assert_equal 0, assigns(:study_subjects).length
			assert_redirected_to find_study_subjects_path(:page => 1)
		end

		test "should find study_subjects by subject_type case and #{cu} login" do
			s1 = Factory(:case_study_subject)
			s2 = Factory(:control_study_subject)
			s3 = Factory(:mother_study_subject)
			login_as send(cu)
			get :find, :subject_type_id => SubjectType['case'].id
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(s1)
		end
	
		test "should find study_subjects by subject_type control and #{cu} login" do
			s1 = Factory(:case_study_subject)
			s2 = Factory(:control_study_subject)
			s3 = Factory(:mother_study_subject)
			login_as send(cu)
			get :find, :subject_type_id => SubjectType['control'].id
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(s2)
		end
	
		test "should find study_subjects by subject_type mother and #{cu} login" do
			s1 = Factory(:case_study_subject)
			s2 = Factory(:control_study_subject)
			s3 = Factory(:mother_study_subject)
			login_as send(cu)
			get :find, :subject_type_id => SubjectType['mother'].id
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(s3)
		end
	
		test "should find study_subjects by first_name and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject, :first_name => "First#{i}" ) }
			login_as send(cu)
			get :find, :first_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects by last_name and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject, :last_name => "Last#{i}" ) }
			login_as send(cu)
			get :find, :last_name => 'st1'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects by maiden_name and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject, :maiden_name => "Maiden#{i}" ) }
			login_as send(cu)
			get :find, :last_name => 'en1'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects with dob as month day year and #{cu} login" do
			base_date = Date.today-100.days
			#	spread dates out by a few days so outside date range
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:dob => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :dob => subjects[1].dob.strftime("%b %d %Y")	#	Dec 1 2000
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects with dob as MM/DD/YYYY and #{cu} login" do
			base_date = Date.today-100.days
			#	spread dates out by a few days so outside date range
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:dob => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :dob => subjects[1].dob.strftime("%m/%d/%Y")	#	javascript selector format
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects with dob as YYYY-MM-DD and #{cu} login" do
			base_date = Date.today-100.days
			#	spread dates out by a few days so outside date range
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:dob => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :dob => subjects[1].dob.to_s	#	same as strftime('%Y-%m-%d')
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects ignoring poorly formatted dob and #{cu} login" do
			base_date = Date.today-100.days
			#	spread dates out by a few days so outside date range
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:dob => base_date + (5*i).days ) }
			login_as send(cu)
			get :find, :dob => 'bad monkey'
			assert_response :success
			assert_equal 3, assigns(:study_subjects).length
		end
	
		test "should find study_subjects with childid and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :childid => '451'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects with patid and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:patid => "345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects with icf_master_id and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:icf_master_id => "345x#{i}" ) }
			login_as send(cu)
			get :find, :icf_master_id => '45x1'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end
	
		test "should find study_subjects with hospital_no and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:patient,:hospital_no => "345#{i}" ).study_subject }
			login_as send(cu)
			get :find, :hospital_no => '451'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end

		%w( state_id_no state_registrar_no local_registrar_no ).each do |field|
	
			test "should find study_subjects by #{field} and #{cu} login" do
				subjects = 3.times.collect{|i| 
					Factory(:study_subject, field => "345x#{i}" ) }
				login_as send(cu)
				get :find, :registrar_no => '45x1'
				assert_response :success
				assert_equal 1, assigns(:study_subjects).length
				assert assigns(:study_subjects).include?(subjects[1])
			end

		end
	
#		test "should find study_subjects by state_id_no and #{cu} login" do
#			3.times{|i| Factory(:study_subject,:state_id_no => "345x#{i}" ) }
#			login_as send(cu)
#			get :find, :registrar_no => '45x1'
#			assert_response :success
#			assert_equal 1, assigns(:study_subjects).length
#		end
#	
#		test "should find study_subjects by state_registrar_no and #{cu} login" do
#			3.times{|i| Factory(:study_subject,:state_registrar_no => "345x#{i}" ) }
#			login_as send(cu)
#			get :find, :registrar_no => '45x1'
#			assert_response :success
#			assert_equal 1, assigns(:study_subjects).length
#		end
#	
#		test "should find study_subjects by local_registrar_no and #{cu} login" do
#			3.times{|i| Factory(:study_subject,:local_registrar_no => "345x#{i}" ) }
#			login_as send(cu)
#			get :find, :registrar_no => '45x1'
#			assert_response :success
#			assert_equal 1, assigns(:study_subjects).length
#		end


	
#	I could add tons of tests for searching on multiple attributes
#	but it would get ridiculous.  I do need to add a few to test the
#	operator parameter so there will be a few here.	

		test "should find study_subjects by first_name OR last_name and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:first_name => "First#{i}", :last_name => "Last#{i}" ) }
			login_as send(cu)
			get :find, :first_name => 'st1', :last_name => 'st2', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
			assert assigns(:study_subjects).include?(subjects[2])
		end

		test "should find study_subjects by first_name AND last_name and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:first_name => "First#{i}", :last_name => "Last#{i}" ) }
			login_as send(cu)
			get :find, :first_name => 'st1', :last_name => 'st1', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end

		test "should find study_subjects by childid OR patid and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451', :childid => '452', :operator => 'OR'
			assert_response :success
			assert_equal 2, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
			assert assigns(:study_subjects).include?(subjects[2])
		end

		test "should find study_subjects by childid AND patid and #{cu} login" do
			subjects = 3.times.collect{|i| 
				Factory(:study_subject,:patid => "345#{i}", :childid => "12345#{i}" ) }
			login_as send(cu)
			get :find, :patid => '451', :childid => '451', :operator => 'AND'
			assert_response :success
			assert_equal 1, assigns(:study_subjects).length
			assert assigns(:study_subjects).include?(subjects[1])
		end



######################################################################
#
#	BEGIN order tests (only on fields in table)
#
		%w( reference_date ).each do |attr|

			test "should find study_subjects and order by #{attr} with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir asc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr, :dir => 'asc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir desc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr, :dir => 'desc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects).reverse
			end
	
			test "should find study_subjects and order by #{attr} invalid dir with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, 
					attr => (Date.today - 100 + i) ) }
				login_as send(cu)
				get :find, :order => attr, :dir => 'invalid'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end

		end

		%w( icf_master_id studyid ).each do |attr|

			test "should find study_subjects and order by #{attr} with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" ) }
				login_as send(cu)
				get :find, :order => attr
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir asc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'asc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir desc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'desc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects).reverse
			end
	
			test "should find study_subjects and order by #{attr} invalid dir with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "12345#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'invalid'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end

		end

		%w( last_name ).each do |attr|

			test "should find study_subjects and order by #{attr} with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir asc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'asc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end
	
			test "should find study_subjects and order by #{attr} dir desc with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'desc'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects).reverse
			end
	
			test "should find study_subjects and order by #{attr} invalid dir with #{cu} login" do
				subjects = 3.times.collect{|i| Factory(:study_subject, attr => "John#{i}" )}
				login_as send(cu)
				get :find, :order => attr, :dir => 'invalid'
				assert_response :success
				assert_equal subjects, assigns(:study_subjects)
			end

		end
#
#	END order tests
#
######################################################################


	end

end

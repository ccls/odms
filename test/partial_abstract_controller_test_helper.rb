module PartialAbstractControllerTestHelper

	def self.included(base)
		base.extend(Tests)
	end

	def factory_attributes(options={})
		Factory.attributes_for(:abstract,options)
	end

	module Tests
	
		def add_abstract_tests

			#	no route
			assert_no_route(:get,:index)

			#	no abstract_id
			assert_no_route(:get,:show)	
			assert_no_route(:get,:new)
			assert_no_route(:post,:create)
			assert_no_route(:get,:edit)
			assert_no_route(:put,:update)
			assert_no_route(:delete,:destroy)

			site_administrators.each do |cu|
			
				test "should show with #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					get :show, :abstract_id => abstract.id
					assert assigns(:abstract)
					assert_response :success
					assert_template 'show'
				end

#				test "should show abstract with pii, patient and identifier and #{cu} login" do
				test "should show abstract with patient and #{cu} login" do
					patient = Factory(:patient)
#					pii = Factory(:pii,:study_subject => patient.study_subject)
#					identifier = Factory(:identifier,:study_subject => patient.study_subject)
					abstract = create_abstract(:study_subject => patient.study_subject)
					login_as send(cu)
					get :show, :abstract_id => abstract.id
					assert assigns(:abstract)
					assert_response :success
					assert_template 'show'
				end
			
				test "should NOT show with invalid abstract_id " <<
						"and #{cu} login" do
					login_as send(cu)
					get :show, :abstract_id => 0
					assert_not_nil flash[:error]
					assert_redirected_to abstracts_path
				end
			
#				test "should edit abstract with pii, patient and identifier and #{cu} login" do
				test "should edit abstract with patient and #{cu} login" do
					patient = Factory(:patient)
#					pii = Factory(:pii,:study_subject => patient.study_subject)
#					identifier = Factory(:identifier,:study_subject => patient.study_subject)
					abstract = create_abstract(:study_subject => patient.study_subject)
					login_as send(cu)
					get :edit, :abstract_id => abstract.id
					assert assigns(:abstract)
					assert_response :success
					assert_template 'edit'
				end

				test "should edit with #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					get :edit, :abstract_id => abstract.id
					assert assigns(:abstract)
					assert_response :success
					assert_template 'edit'
				end
			
				test "should NOT edit with invalid " <<
						"abstract_id and #{cu} login" do
					login_as send(cu)
					get :edit, :abstract_id => 0
					assert_redirected_to abstracts_path
				end
			
				test "should update with #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					put :update, :abstract_id => abstract.id,
						:abstract => factory_attributes
					assert assigns(:abstract)
					assert_redirected_to :action => 'show'	#abstract_path(abstract)
				end
			
				test "should NOT update with invalid " <<
						"abstract_id and #{cu} login" do
					login_as send(cu)
					put :update, :abstract_id => 0,
						:abstract => factory_attributes
					assert_redirected_to abstracts_path
				end

				test "should NOT update with #{cu} " <<
						"login when update fails" do
					abstract = create_abstract(:updated_at => ( Time.now - 1.day ) )
					Abstract.any_instance.stubs(:create_or_update).returns(false)
					login_as send(cu)
					deny_changes("Abstract.find(#{abstract.id}).updated_at") {
						put :update, :abstract_id => abstract.id,
							:abstract => factory_attributes
					}
					assert assigns(:abstract)
					assert_response :success
					assert_template 'edit'
					assert_not_nil flash[:error]
				end

				test "should NOT update with #{cu} " <<
						"login and invalid abstract" do
					abstract = create_abstract(:updated_at => ( Time.now - 1.day ) )
					Abstract.any_instance.stubs(:valid?).returns(false)
					login_as send(cu)
					deny_changes("Abstract.find(#{abstract.id}).updated_at") {
						put :update, :abstract_id => abstract.id,
							:abstract => factory_attributes
					}
					assert assigns(:abstract)
					assert_response :success
					assert_template 'edit'
					assert_not_nil flash[:error]
				end

#				test "should update and redirect to edit next section " <<
#						"with #{cu} login and commit = 'edit_next'" do
				test "should update and redirect to edit next section " <<
						"with #{cu} login and edit_next is set" do
					abstract = create_abstract
					login_as send(cu)
					put :update, :abstract_id => abstract.id, :abstract => {},
						:edit_next => 'something'
#						:commit => 'edit_next'
					assert assigns(:abstract)
					sections = Abstract.sections
#					ci = sections.find_index{|i| i[:controller] == @controller.class.name }
					ci = sections.find_index{|i| 
						i[:controller] == @controller.class.name.demodulize }
					if( !ci.nil? && ci < ( sections.length - 1 ) )
						assert_redirected_to send(sections[ci+1][:edit],abstract)
					end
				end

#				test "should update and redirect to edit previous section " <<
#						"with #{cu} login and commit = 'edit_previous'" do
				test "should update and redirect to edit previous section " <<
						"with #{cu} login and edit_previous is set" do
					abstract = create_abstract
					login_as send(cu)
					put :update, :abstract_id => abstract.id, :abstract => {},
						:edit_previous => 'something'
#						:commit => 'edit_previous'
					assert assigns(:abstract)
					sections = Abstract.sections
#					ci = sections.find_index{|i| i[:controller] == @controller.class.name }
					ci = sections.find_index{|i| 
						i[:controller] == @controller.class.name.demodulize }
					if( !ci.nil? && ci > 0 )
						assert_redirected_to send(sections[ci-1][:edit],abstract)
					end
				end

				test "should update and redirect to show section " <<
						"with #{cu} login and commit = 'anythingelse'" do
					abstract = create_abstract
					login_as send(cu)
					put :update, :abstract_id => abstract.id, :abstract => {},
						:commit => 'anythingelse'
					assert assigns(:abstract)
					assert_redirected_to :action => 'show'
				end

				test "should update and redirect to show section " <<
						"with #{cu} login and commit not set" do
					abstract = create_abstract
					login_as send(cu)
					put :update, :abstract_id => abstract.id, :abstract => {}
					assert assigns(:abstract)
					assert_redirected_to :action => 'show'
				end

			end
			
			non_site_administrators.each do |cu|
			
				test "should NOT show with #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					get :show, :abstract_id => abstract.id
					assert_not_nil flash[:error]
					assert_redirected_to root_path
				end
			
				test "should NOT show with invalid abstract_id " <<
						"and #{cu} login" do
					login_as send(cu)
					get :show, :abstract_id => 0
					assert_not_nil flash[:error]
					assert_redirected_to root_path
				end
			
				test "should NOT edit with #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					get :edit, :abstract_id => abstract.id
					assert_not_nil flash[:error]
					assert_redirected_to root_path
				end
			
				test "should NOT edit with invalid " <<
						"abstract_id and #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					get :edit, :abstract_id => 0
					assert_not_nil flash[:error]
					assert_redirected_to root_path
				end
			
				test "should NOT update with #{cu} login" do
					abstract = create_abstract
					login_as send(cu)
					put :update, :abstract_id => abstract.id,
						:abstract => factory_attributes
					assert_not_nil flash[:error]
					assert_redirected_to root_path
				end
			
				test "should NOT update with invalid " <<
						"abstract_id and #{cu} login" do
					login_as send(cu)
					put :update, :abstract_id => 0,
						:abstract => factory_attributes
					assert_not_nil flash[:error]
					assert_redirected_to root_path
				end
			
			end
	
			test "should NOT show without login" do
				abstract = create_abstract
				get :show, :abstract_id => abstract.id
				assert_redirected_to_login
			end
		
			test "should NOT show with invalid abstract_id " <<
					"and without login" do
				get :show, :abstract_id => 0
				assert_redirected_to_login
			end
		
			test "should NOT edit without login" do
				abstract = create_abstract
				get :edit, :abstract_id => abstract.id
				assert_redirected_to_login
			end
		
			test "should NOT edit with invalid " <<
					"abstract_id and without login" do
				get :edit, :abstract_id => 0
				assert_redirected_to_login
			end
		
			test "should NOT update without login" do
				abstract = create_abstract
				put :update, :abstract_id => abstract.id,
					:abstract => factory_attributes
				assert_redirected_to_login
			end
		
			test "should NOT update with invalid " <<
					"abstract_id and without login" do
				put :update, :abstract_id => 0,
					:abstract => factory_attributes
				assert_redirected_to_login
			end
		end	#	add_abstract_tests
	end	#	Tests
end	#	PartialAbstractControllerTestHelper
ActionController::TestCase.send(:include,PartialAbstractControllerTestHelper)

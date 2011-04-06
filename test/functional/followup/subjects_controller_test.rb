require 'test_helper'

class Followup::SubjectsControllerTest < ActionController::TestCase

	setup :create_home_exposure_with_subject
	ASSERT_ACCESS_OPTIONS = {
		:model => 'Subject',
		:actions => [:index,:show,:edit],	#,:update],
#		:before => :create_home_exposure_subjects,
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_subject
	}
	def factory_attributes(options={})
		Factory.attributes_for(:subject,{
			:subject_type_id => Factory(:subject_type).id,
			:race_id => Factory(:race).id}.merge(options))
	end

#	This controller isn't exactly restful
#	and doesn't actually edit the subject.

	assert_access_with_login({ 
		:logins => [:superuser,:admin,:reader,:editor] })
	assert_no_access_with_login({ 
		:logins => [:active_user] })
	assert_no_access_without_login

	assert_access_with_https
	assert_no_access_with_http


%w( superuser admin reader editor ).each do |u|

	test "should download csv with #{u} login" do
		login_as send(u)
		get :index, :commit => 'download'
		assert_response :success
		assert_not_nil @response.headers['Content-disposition'].match(/attachment;.*csv/)
	end

	test "should create subject's hx_gift_card if none " <<
			"with #{u} login" do
		login_as send(u)
		subject = create_hx_subject
		gift_card = create_gift_card(:project => Project['HomeExposures'])
		assert_nil gift_card.subject
		assert_nil subject.hx_gift_card
		put :update, :id => subject.id, :gift_card => { :id => gift_card.id }
		assert_equal subject.reload.hx_gift_card, gift_card.reload
		assert_equal subject, assigns(:subject)
		assert_redirected_to followup_subject_path(subject)
	end

	test "should change subject's hx_gift_card if exists " <<
			"with #{u} login" do
		login_as send(u)
		subject = create_hx_subject_with_gift_card
#		gift_card_1 = subject.hx_gift_card	
#	this doesn't simply assign the GC, it keeps the association?  calling gift_card_1.reload effectively re-searches for subject's hx_gift_card, NOT reloading the gift card by id!, which seems very, very wrong to me.
		gift_card_1 = GiftCard.find(subject.hx_gift_card.id)
		gift_card_2 = create_gift_card(:project => Project['HomeExposures'])
		assert_nil gift_card_2.subject
		assert_not_nil subject.reload.hx_gift_card
		put :update, :id => subject.id, :gift_card => { :id => gift_card_2.id }
		assert_not_nil gift_card_2.reload.subject
		assert_nil     gift_card_1.reload.subject
		assert_not_nil subject.reload.hx_gift_card
		assert_equal subject.reload.hx_gift_card, gift_card_2
		assert_equal subject, assigns(:subject)
		assert_redirected_to followup_subject_path(subject)
	end

	test "should NOT update gift_card when invalid with #{u} login" do
		login_as send(u)
		subject = create_hx_subject_with_gift_card
		GiftCard.any_instance.stubs(:valid?).returns(false)
		deny_changes("GiftCard.find(#{subject.hx_gift_card.id}).updated_at") {
			put :update, :id => subject.id, :gift_card => { :id => subject.hx_gift_card.id }
		}
		assert_not_nil flash[:error]
		assert_template 'edit'
		assert_response :success
	end

	test "should NOT update gift_card when save fails with #{u} login" do
		login_as send(u)
		subject = create_hx_subject_with_gift_card
		GiftCard.any_instance.stubs(:create_or_update).returns(false)
		deny_changes("GiftCard.find(#{subject.hx_gift_card.id}).updated_at") {
			put :update, :id => subject.id, :gift_card => { :id => subject.hx_gift_card.id }
		}
		assert_not_nil flash[:error]
		assert_template 'edit'
		assert_response :success
	end

	test "should NOT update gift_card without gift_card param with #{u} login" do
		login_as send(u)
		subject = create_hx_subject_with_gift_card
		deny_changes("GiftCard.find(#{subject.hx_gift_card.id}).updated_at") {
			put :update, :id => subject.id
		}
		assert_not_nil flash[:error]
		assert_redirected_to followup_subjects_path
	end

	test "should NOT update gift_card without gift_card id param with #{u} login" do
		login_as send(u)
		subject = create_hx_subject_with_gift_card
		deny_changes("GiftCard.find(#{subject.hx_gift_card.id}).updated_at") {
			put :update, :id => subject.id, :gift_card => {}
		}
		assert_not_nil flash[:error]
		assert_redirected_to followup_subjects_path
	end

	test "should NOT update gift_card without existing gift_card id with #{u} login" do
		login_as send(u)
		subject = create_hx_subject_with_gift_card
		deny_changes("GiftCard.find(#{subject.hx_gift_card.id}).updated_at") {
			put :update, :id => subject.id, :gift_card => { :id => 0 }
		}
		assert_not_nil flash[:error]
		assert_redirected_to followup_subjects_path
	end

end

%w( active_user ).each do |u|

	test "should NOT download csv with #{u} login" do
		login_as send(u)
		get :index, :commit => 'download'
		assert_redirected_to root_path
		assert_not_nil flash[:error]
	end

end

	test "should NOT download csv without login" do
		get :index, :commit => 'download'
		assert_redirected_to_login
	end

protected

	def create_hx_subject_with_gift_card
		subject = create_hx_subject
		gift_card = create_gift_card(:project => Project['HomeExposures'])
		assert_nil gift_card.subject
		assert_nil subject.hx_gift_card
		gift_card.update_attribute(:subject, subject)
		assert_not_nil gift_card.subject
		assert_not_nil subject.reload.hx_gift_card
		subject.reload
	end

end

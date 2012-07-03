require 'test_helper'

class SampleLocationsControllerTest < ActionController::TestCase

	ASSERT_ACCESS_OPTIONS = {
		:model => 'SampleLocation',
		:actions => [:new,:create,:edit,:update,:show,:index,:destroy],
		:attributes_for_create => :factory_attributes,
		:method_for_create => :create_sample_location
	}

	def factory_attributes(options={})
		Factory.attributes_for(:sample_location,{
			:organization_id => Factory(:organization).id
		}.merge(options))
	end

	assert_access_with_login({    :logins => site_administrators })
	assert_no_access_with_login({ :logins => non_site_administrators })
	assert_no_access_without_login

end
__END__
  setup do
    @sample_location = sample_locations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sample_locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sample_location" do
    assert_difference('SampleLocation.count') do
      post :create, sample_location: { is_active: @sample_location.is_active, notes: @sample_location.notes, organization_id: @sample_location.organization_id, position: @sample_location.position }
    end

    assert_redirected_to sample_location_path(assigns(:sample_location))
  end

  test "should show sample_location" do
    get :show, id: @sample_location
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sample_location
    assert_response :success
  end

  test "should update sample_location" do
    put :update, id: @sample_location, sample_location: { is_active: @sample_location.is_active, notes: @sample_location.notes, organization_id: @sample_location.organization_id, position: @sample_location.position }
    assert_redirected_to sample_location_path(assigns(:sample_location))
  end

  test "should destroy sample_location" do
    assert_difference('SampleLocation.count', -1) do
      delete :destroy, id: @sample_location
    end

    assert_redirected_to sample_locations_path
  end
end

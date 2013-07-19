require 'test_helper'

class ExperimentsControllerTest < ActionController::TestCase
  setup do
    @dashboard = experiments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:experiments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dashboard" do
    assert_difference('Dashboard.count') do
      post :create, dashboard: {  }
    end

    assert_redirected_to dashboard_path(assigns(:dashboard))
  end

  test "should show dashboard" do
    get :show, id: @dashboard
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dashboard
    assert_response :success
  end

  test "should update dashboard" do
    put :update, id: @dashboard, dashboard: {  }
    assert_redirected_to dashboard_path(assigns(:dashboard))
  end

  test "should destroy dashboard" do
    assert_difference('Dashboard.count', -1) do
      delete :destroy, id: @dashboard
    end

    assert_redirected_to experiments_path
  end
end

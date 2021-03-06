require "test_helper"

class Admin::RedeemRequestsControllerTest < ActionController::TestCase 
 
  test "must get users redemption requests" do
    seed_data
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
  end
  
  test "should not update redeem_request without any parameter" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_raises ActionController::ParameterMissing do 
      put :update, :id => redeem_request.id
    end
  end
  
  test "must update redeem_requests when coupon_code is changed" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    updated_coupon_code = 'josh24'
    patch :update, :id => redeem_request.id, redeem_request: {:coupon_code => updated_coupon_code}
    redeem_request.reload
    assert_equal updated_coupon_code, redeem_request.coupon_code
    assert_response :redirect  
  end
   
  test "must update redeem_requests when comment is changed" do
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    updated_comment = Faker::Lorem.word
    patch :update, :id => redeem_request.id, redeem_request: {:comment => updated_comment}
    redeem_request.reload
    assert_equal updated_comment, redeem_request.comment
    assert_response :redirect  
  end
 
  test "should destroy redeem_request" do 
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_difference('RedeemRequest.count', -1) do
      delete :destroy, id: redeem_request.id
    end
    assert_response :redirect
  end  

  test "should destroy transaction corresponding to redeem_request" do 
    seed_data
    redeem_request = create(:redeem_request,:points => 100, user: @user)
    assert_difference('Transaction.count', -1) do
      delete :destroy, id: redeem_request.id
    end
    assert_response :redirect
  end

  test "should render index template" do
    seed_data
    redeem_request = create(:redeem_request,:points => 10, user: @user)
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
    assert_template 'redeem_requests/index'
    assert_template 'redeem_requests/_tagtable'
    assert_template 'redeem_requests/_redeem_request' 
  end
 
  test "status should either be open or close" do
    seed_data
    redeem_request = create(:redeem_request,:points => 10, user: @user)
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
    assert_not_nil assigns(:status)
  end
 
  test "on status open should render all whose status are open" do
    seed_data
    redeem_request = create_list(:redeem_request, 3, :points => 2, :status => false, user: @user)
    xhr :get, :index, parameters, format: :js,  :id => @user.id
    assert_response :success
    assert_not_nil assigns(:status)
    assert_equal redeem_request.count, 3
  end
 
  def seed_data
    round = create(:round, :status => 'open')
    role = create(:role, :name => 'Admin')
    @user = create(:user, :auth_token => 'dah123rty', goal: create(:goal))
    @user.roles << role
    sign_in @user
    transaction = create(:transaction, :type => 'credit', :points => 120, user: @user)
  end

  def parameters
    {"redeem_request"=>{'coupon_code' => 'josh12' ,'points' => '100'}}
  end

end

require 'test_helper'

class MoneyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @money = money(:one)
  end

  test "should get index" do
    get money_index_url
    assert_response :success
  end

  test "should get new" do
    get new_money_url
    assert_response :success
  end

  test "should create money" do
    assert_difference('Money.count') do
      post money_index_url, params: { money: {  } }
    end

    assert_redirected_to money_url(Money.last)
  end

  test "should show money" do
    get money_url(@money)
    assert_response :success
  end

  test "should get edit" do
    get edit_money_url(@money)
    assert_response :success
  end

  test "should update money" do
    patch money_url(@money), params: { money: {  } }
    assert_redirected_to money_url(@money)
  end

  test "should destroy money" do
    assert_difference('Money.count', -1) do
      delete money_url(@money)
    end

    assert_redirected_to money_index_url
  end
end

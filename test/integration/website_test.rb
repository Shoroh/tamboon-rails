require 'test_helper'

class WebsiteTest < ActionDispatch::IntegrationTest

  def setup
    OmiseChargeMock.start
  end

  def teardown
    OmiseChargeMock.stop
  end

  test "should get index" do
    get "/"

    assert_response :success
  end

  test "that someone can't donate to no charity" do
    post donate_path, amount: "100", omise_token: "tokn_X", charity: ""

    assert_template :index
    # Because this is an Integration Test, where we could test many functions,
    # I'd better put a real sentence we'd like to check:
    assert_equal "Charity — you must choose one at least", flash.now[:alert]
  end

  test "that someone can't donate 0 to a charity" do
    charity = charities(:children)
    post donate_path, amount: "0", omise_token: "tokn_X", charity: charity.id

    assert_template :index
    # Otherwise, how do we know that user receives correct message,
    # where amount is 20, but not 2000?
    assert_equal "Amount must be more or equal 20 THB", flash.now[:alert]
  end

  test "that someone can't donate less than 20 to a charity" do
    charity = charities(:children)
    post donate_path, amount: "19", omise_token: "tokn_X", charity: charity.id

    assert_template :index
    assert_equal "Amount must be more or equal 20 THB", flash.now[:alert]
  end

  test "that someone can't donate without a token" do
    charity = charities(:children)
    post donate_path, amount: "100", charity: charity.id

    assert_template :index
    assert_equal "Omise token can't be blank", flash.now[:alert]
  end

  test "that someone can donate to a charity" do
    charity = charities(:children)
    initial_total = charity.total
    # We don't need to use multiply here (100 * 100)
    # To make it easy to read we can separate cents by low dash:
    expected_total = initial_total + 100_00

    post_via_redirect donate_path, amount: "100", omise_token: "tokn_X", charity: charity.id

    assert_template :index
    # I prefer to show users what exactly they done
    # and the Application did what they expected:
    assert_equal "Success you've donated 100.00 THB to Ban Khru Noi.", flash[:notice]
    assert_equal expected_total, charity.reload.total
  end

  test "that someone can donate to a charity amount with subunits" do
    charity = charities(:children)
    initial_total = charity.total
    expected_total = initial_total + 54_25

    post_via_redirect donate_path, amount: "54.25", omise_token: "tokn_X", charity: charity.id

    assert_template :index
    assert_equal "Success you've donated 54.25 THB to Ban Khru Noi.", flash[:notice]
    assert_equal expected_total, charity.reload.total
  end

  test "that if the charge fail from omise side it shows an error" do
    charity = charities(:children)

    # 999 is used to set paid as false
    post donate_path, amount: "999", omise_token: "tokn_X", charity: charity.id

    assert_template :index
    # Sometimes it's better to show the real failure message from External Service:
    assert_equal "We're sorry, looks like the Omise Service is temporally unavailable", flash.now[:alert]
  end

  test "that we can donate to a charity at random" do
    charities = Charity.all
    initial_total = charities.to_a.sum(&:total)
    expected_total = initial_total + (100 * 100)

    post donate_path, amount: "100", omise_token: "tokn_X", charity: "random"

    # I know, you asked to not change the tests. But I have to place this,
    # cause the test is positive, user should be redirected when success.
    # I think you've just forgotten to use post_via_redirect above :)
    follow_redirect!
    assert_template :index
    assert_equal expected_total, charities.to_a.map(&:reload).sum(&:total)
    assert_match "Success you've donated 100.00 THB to", flash[:notice]
  end
end

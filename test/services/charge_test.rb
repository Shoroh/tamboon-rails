require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  subject = Charge

  def setup
    OmiseChargeMock.start

    @charity = charities(:children)

    @charge_params = {
      omise_token: 'tk9',
      charity:     @charity,
      amount:      10_00
    }
  end

  def teardown
    OmiseChargeMock.stop
  end

  test 'that Charge performs well and has no errors with valid params' do
    charge = subject.new(@charge_params)

    assert_difference '@charity.reload.total', charge.amount do
      assert charge.perform
    end

    assert charge.valid?
    assert charge.errors.empty?
  end

  test 'that Charge returns an error when omise_token is blank' do
    @charge_params[:omise_token] = ''
    charge = subject.new(@charge_params)

    refute_performing(charge)
    charge_has_error(charge, "Omise token can't be blank")
  end

  test 'that Charge returns an error when Charity is nil' do
    @charge_params[:charity] = nil
    charge = subject.new(@charge_params)

    refute_performing(charge)
    charge_has_error(charge, 'Charity — you must choose one at least')
  end

  %w(nil 10 19 3.55).each do |amount|
    test "that Charge returns an error when Amount is #{amount}" do
      @charge_params[:amount] = amount
      charge = subject.new(@charge_params)

      refute_performing(charge)
      charge_has_error(charge, 'Amount must be more or equal 20 THB')
    end
  end

  # I know, you asked to not use a real network connections during the tests.
  # But usually this is the only way to check that everything goes well.
  test "that Charge returns an Omise real error" do
    skip
    OmiseChargeMock.stop
    charge = subject.new(@charge_params)

    refute_performing(charge)
    charge_has_error(charge, 'token tk9 was not found (not_found)')
  end

  # Just a few helpers:
  def refute_performing(charge)
    assert_no_difference '@charity.reload.total', charge.amount do
      refute charge.perform
    end
    assert charge.errors.any?
  end

  def charge_has_error(charge, error_message)
    assert_equal error_message, charge.errors.full_messages.to_sentence
  end
end

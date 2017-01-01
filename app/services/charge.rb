class Charge
  include ActiveModel::Model
  MIN_AMOUNT_CENTS = 2000.freeze

  attr_reader :charity, :amount
  attr_accessor :omise_token

  validates :omise_token, presence: true
  validates :charity, presence: true
  validates :amount, numericality: {
    only_integer: true,
    greater_than_or_equal_to: MIN_AMOUNT_CENTS,
    message: I18n.t('.greater_than_or_equal_to'), min: Money.new(MIN_AMOUNT_CENTS).to_i
  }

  def perform
    valid? ? pay! : false
  end

  def amount=(amount)
    @amount = MoneyParser.to_cents(amount)
  end

  def charity=(charity)
    @charity = Charity.find_or_random(charity)
  end

  def retrieve_token
    omise_token ? Omise::Token.retrieve(omise_token) : nil
  end

  private

  def pay!
    begin
      if charge.paid
        charity.credit_amount(charge.amount)
      else
        add_error charge.failure_message
      end
    rescue Omise::Error => e
      add_error e.message
    end
  end

  def add_error(error_message=nil)
    errors[:base] << error_message if error_message
    false
  end

  def charge
    @charge ||= Omise::Charge.create(charge_params)
  end

  def charge_params
    {
      amount: amount,
      currency: 'THB',
      card: omise_token,
      description: "Donation to #{charity.name} [#{charity.id}]",
    }
  end
end

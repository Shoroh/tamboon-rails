module OmiseChargeMock
  # Save the original methods into variables before we change them:
  @original_charge_method = Charge.instance_method(:charge)
  @original_retrieve_token_method = Charge.instance_method(:retrieve_token)

  def self.start
    Charge.class_eval do
      def charge
        @charge ||= OpenStruct.new({
          amount: amount,
          paid: (amount != 99900),
          failure_message: "We're sorry, looks like the Omise Service is temporally unavailable"
        })
      end

      def retrieve_token
        OpenStruct.new({
          id: 'tokn_X',
          card: OpenStruct.new({
            name: 'J DOE',
            last_digits: '4242',
            expiration_month: 10,
            expiration_year: 2020,
            security_code_check: false
          })
        })
      end
    end
  end

  def self.stop
    # And restoring the original methods:
    original_charge_method = @original_charge_method
    original_retrieve_token_method = @original_retrieve_token_method
    Charge.class_eval do
      define_method :charge, original_charge_method
      define_method :charge, original_retrieve_token_method
    end
  end
end

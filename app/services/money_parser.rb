module MoneyParser
  # Converts any user inputs like '1,000.00' or '1,000'
  # to integer in satangs like 1_000_00
  def self.to_cents(user_input)
    splitted_input = user_input.to_s.gsub(/[^\d.]/, '').split('.')
    fractional     = splitted_input[1].to_i
    total_cents    = splitted_input[0].to_i * 100
    total_cents + fractional
  end
end

require 'test_helper'

class MoneyParserTest < ActiveSupport::TestCase
  subject = MoneyParser

  # Testing MoneyParser#parse_to_cents
  {
    '1000.00'  => 1_000_00,
    '1,000.00' => 1_000_00,
    '1,000.12' => 1_000_12,
    '99.00'    => 99_00,
    '9.99'     => 9_99,
    '12'       => 12_00,
    '.45'      => 45,
    'add9.99c' => 9_99,
    '   5.25 ' => 5_25,
    '10'       => 10_00
  }.each_pair do |input, result|

    test "that #{input} must be converted to #{result}" do
      assert_equal result, subject.to_cents(input)
    end

  end
end

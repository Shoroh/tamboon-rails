class Charity < ActiveRecord::Base
  include Randomable

  validates :name, presence: true

  def self.find_or_random(charity_id)
    charity_id == 'random' ? random : find_by_id(charity_id)
  end

  def credit_amount(amount)
    # All we have to do is just to update the current amount of total:
    new_total = reload.total + amount
    update_attribute :total, new_total
  end
end

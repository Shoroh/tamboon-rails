class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    # All we have to do is just to update the current amount of total:
    new_total = reload.total + amount
    update_attribute :total, new_total
  end
end

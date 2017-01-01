class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    charge = Charge.new(charge_params)

    if charge.perform
      flash.notice = t(".success",
        amount: Money.new(charge.amount).to_s,
        charity: charge.charity.name
      )
      redirect_to root_path
    else
      @token = charge.retrieve_token
      flash.now.alert = charge.errors.full_messages.to_sentence
      render :index
    end
  end

  private

  def charge_params
    params.permit(:omise_token, :charity, :amount)
  end
end

class ChargeForm
  constructor: (@$chargeForm) ->
    @$omiseToken = @$chargeForm.find("[name=omise_token]")
    @$submitButton = @$chargeForm.find("input[type=submit]")

    @$name = @$chargeForm.find("[data-omise=holder_name]")
    @$number = @$chargeForm.find("[data-omise=number]")
    @$expirationMonth = @$chargeForm.find("[data-omise=expiration_month]")
    @$expirationYear = @$chargeForm.find("[data-omise=expiration_year]")
    @$securityCode = @$chargeForm.find("[data-omise=security_code]")

    @$alertContainer = $(".cc_error")

    @_formHandler()

  _formHandler: ->
    @$chargeForm.on 'submit', (e) =>
      @$alertContainer.html('')
      @$submitButton.prop 'disabled', true
      if @$omiseToken.val().length
        @$chargeForm.get(0).submit()
      else
        @_getToken()
      false

  _getToken: ->
    Omise.createToken "card", @_cardHash(), (status, response) =>
      if response.object == 'error'
        @$alertContainer.html(response.message)
        @$submitButton.prop 'disabled', false
      else
        @$omiseToken.val(response.id)
        @$chargeForm.get(0).submit()

  _cardHash: ->
    "name": @$name.val(),
    "number": @$number.val(),
    "expiration_month": @$expirationMonth.val(),
    "expiration_year": @$expirationYear.val(),
    "security_code": @$securityCode.val()

$(document).on 'ready', ->
  $chargeForm = $('#donate')
  new ChargeForm($chargeForm) if $chargeForm.length

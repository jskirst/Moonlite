$.MB ||= {}
$.MB.Checkout ||= {}

$.MB.Checkout.init = ->
  console.log "Setting up checkout form..."
  console.log "Stripe Public Key: " + $("meta[name='stripe:key']").attr('content')
  Stripe.setPublishableKey($("meta[name='stripe:key']").attr('content'))
  $("#new_subscription").submit ->
    $form = $(this)
    $form.find("input[type=submit]").prop("disabled", true).addClass("disabled")
    Stripe.createToken($form, $.MB.Checkout.stripeResponseHandler)
    false
  console.log "Checkout form configured."
  
$.MB.Checkout.stripeResponseHandler = (status, response) ->
  $form = $("#new_subscription")
  
  if response.error
    $form.find(".payment-errors").text(response.error.message)
    $form.find("input[type=submit]").prop('disabled', false).removeClass("disabled")
  else
    token = response.id
    $form.find("#group_stripe_token").val(token)
    $form.get(0).submit()
    
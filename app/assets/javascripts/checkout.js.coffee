$.MB ||= {}
$.MB.Checkout ||= {}

$.MB.Checkout.init = ->
  $("#new_group").submit ->
    $(".errors").text("")
    valid = true
    $($("#new_group input[type=text], #new_group input[type=password]").get().reverse()).each ->
      if $(this).val() == ""
        $(".errors").show().text("Please enter "+$(this).data("label")+".")
        valid = false
        stopSpinner();
    return valid
  
  $("#new_group").on "ajax:success", (status, response) ->
    $form = $(this)
    if response.error
      console.log response.error
      $form.find(".errors").text(response.error)
    else
      $form.find("#group_token").val(response.token)
      $.MB.Checkout.sendToStripe()

$.MB.Checkout.sendToStripe = ->
  Stripe.setPublishableKey($("meta[name='stripe:key']").attr('content'))
  $form = $("#new_group")
  $form.find("input[type=submit]").prop("disabled", true).addClass("disabled")
  Stripe.createToken($form, $.MB.Checkout.stripeResponseHandler)
  
$.MB.Checkout.stripeResponseHandler = (status, response) ->
  $form = $("#new_group")
  if response.error
    $form.find(".errors").text(response.error.message)
    $form.find("input[type=submit]").prop('disabled', false).removeClass("disabled")
    stopSpinner()
  else
    stripe_token = response.id
    $form.find("#group_stripe_token").val(stripe_token)
    $form.get(0).submit()
    
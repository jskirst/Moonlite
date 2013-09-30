$.MB ||= {}
$.MB.Checkout ||= {}

$.MB.Checkout.init = ->
  $("#new_group").submit ->
    $(".errors").text("")
    valid = true
    $($("#new_group input[type=text][data-label], #new_group input[type=password][data-label]").get().reverse()).each ->
      if $(this).val() == ""
        $(".errors").show().text("Please enter "+$(this).data("label")+".")
        valid = false
        stopSpinner();
    if valid
      $(this).find("input").attr("readonly", true)
    return valid
    
  $("#new_group").on "ajax:success", (status, response) ->
    $form = $(this)
    if response.error
      $form.find(".errors").text(response.error)
      $(this).find("input").removeAttr("readonly")
    else
      $(".in-progress").show()
      $form.find("#group_token").val(response.token)
      $.MB.Checkout.sendToStripe()

$.MB.Checkout.sendToStripe = ->
  Stripe.setPublishableKey($("meta[name='stripe:key']").attr('content'))
  $form = $("#new_group")
  $form.find("input[type=submit]").prop("disabled", true).addClass("disabled")
  Stripe.createToken($form, $.MB.Checkout.stripeResponseHandler)
  $form.find("input[type=submit]").prop('disabled', true).addClass("disabled")
  
$.MB.Checkout.stripeResponseHandler = (status, response) ->
  $form = $("#new_group")
  if response.error
    $form.find(".errors").text(response.error.message)
    $form.find("input[type=submit]").prop('disabled', false).removeClass("disabled")
    $(".in-progress").hide();
    stopSpinner()
    $form.find("input").removeAttr("readonly")
  else
    stripe_token = response.id
    if $("#group_token").val().length > 0
      $form.find("input[type=submit]").prop('disabled', true).addClass("disabled")
      $form.find("#group_stripe_token").val(stripe_token)
      $form.removeAttr("data-remote").unbind("ajax:success").submit().on "ajax:success", ->
        window.location = "/g/purchased"
    else
      alert "An error occurred processing your transaction. No amount was charged to your account."
    
$.MB ||= {}

$.MB.log = (str) ->
  if $.MB.env == "development"
    if console
      if console.log
        console.log(str)

$.MB.next_headline = ($headline) ->
  $headline.fadeOut 700, ->
    $(this).remove()
    if $('.headlines').size() > 0
      $('.headlines:first').show()
    else
      $('.launchpadcontent').show()
      $(".modal_close").show();
      
$.MB.checkSubmit = (e, input) ->
  if e && e.keyCode == 13
    $(input).parents('form').submit()

$.MB.submit_or_close = (exit_button) ->
  if $("#user_email").val() == ""
    $.MB.next_headline($(exit_button).parents('.headlines'))
  else
    $('#update_name').submit()
    
$ ->
  $('select#user_country').change (event) ->
    $('select#user_state').attr('disabled', true)
    country_code = $(this).val();
    url = "/sections/subregion_options?parent_region=#{country_code}"
    $('select#user_state').load(url).removeAttr("disabled")
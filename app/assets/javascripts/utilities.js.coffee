$.MB ||= {}

$.MB.log = (str) ->
  if console
    if console.log
      console.log(str)

$.MB.next_headline = ($headline) ->
  $headline.fadeOut 700, ->
    $(this).addClass("cleared")
    if $('.headlines').not(".cleared").size() > 0
      $('.headlines').not(".cleared").first().show()
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
    
$.MB.show_loading_icon = ->
  $("#page_loading").show()
  setTimeout("$('#page_loading').hide();", 6000)
  
$.MB.trigger_event = (doc, name) ->
  event = doc.createEvent 'Events'
  event.initEvent name, true, true
  doc.dispatchEvent event
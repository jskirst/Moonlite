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
    
$.MB.show_loading_icon = ->
  $("#page_loading").show()
  setTimeout("$('#page_loading').hide();", 6000)
  #if $.data(document.body, 'reload') == true
    #$("#page_loading").show()
    #setTimeout("$('#page_loading').hide();", 6000)
  #else
    #log("reset load;")
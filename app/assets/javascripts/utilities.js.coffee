$.MB ||= {}

$.log = (str) ->
  if $.MB.env == "development"
    if console
      if console.log
        console.log(str)

$.next_headline = ($headline) ->
  $headline.fadeOut 700, ->
    $(this).remove()
    if $('.headlines').size() > 0
      $('.headlines:first').show()
    else
      $('.launchpadcontent').show()
      $(".modal_close").show();
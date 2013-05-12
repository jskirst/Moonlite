$.MB ||= {}
$.MB.Arena ||= {}

$.MB.Arena.count_down_points = ->
  if $.points_remaining > 0 and $.continue_countdown == true
    $.points_remaining = $.points_remaining - 1
    $(".pointbarfiller").parent().find("div.pointbartext").text($.points_remaining + " points")
    $("#points_remaining").val($.points_remaining);
    setTimeout($.MB.Arena.count_down_points, 450)
  else
    $.continue_countdown = false

$.MB.Arena.count_down_bar = ->
  if $.continue_countdown == true
    $bar = $(".pointbarfiller")
    $.percent_remaining = $.percent_remaining - .1
    $bar.css("width", $.percent_remaining+"%")
    setTimeout($.MB.Arena.count_down_bar, 45)
    
$.MB.Arena.start_countdown = ->
  setTimeout ->
    setTimeout($.MB.Arena.count_down_bar, 450)
    setTimeout($.MB.Arena.count_down_points, 450)
  ,3000

$.MB.Arena.init = (options = {}) ->
  $.continue_countdown = true
  $.percent_remaining = 100
  $.points_remaining = 100
  
  $(".answer_content").unbind();
  $("#challenge_form").unbind();
  $("#challenge_form").on "submit", ->
    $.continue_countdown = false
    return true
  
  $(".answer_content").on "click", ->
    $(this).css('background-color', '#C6C6DA')
    $.continue_countdown = false
    $(this).find("input").attr("checked", "checked")
    $("#challenge_form").submit()
    $(".answer_content").unbind()
    $.MB.Arena.initialized = false
  
  $("#challenge_form").on "ajax:error", (xhr, data) ->
    location.reload()
  
  $("#challenge_form").on "ajax:success", (xhr, data) ->
    if data.type == "multiple"
      $("#answer_"+data.correct_answer).css("background-color", "rgba(104, 231, 104, 0.79)").css("color", "white")
      if not data.correct
        $("#answer_"+data.supplied_answer).css("background-color", "#FF9999").css("color", "white")
    else if data.type == "exact"
      if data.correct == true
        $(".match_status_text").css("font-size", "22px").css("color", "rgb(0, 206, 0)").css("margin-left", "12px").css("font-weight", "bold").text("Correct!")
        $(".answer_feedback").css("border-color", "rgba(3, 233, 12, 0.8)").css("-moz-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(0, 255, 41, 0.6)").css("-webkit-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(0, 255, 41, 0.6)").css("box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(0, 255, 41, 0.6)")
      else
        $(".match_status_text").css("font-size", "22px").css("color", "rgb(233, 0, 0);").css("margin-left", "12px").css("font-weight", "bold").text("Incorrect...")
        $(".match_status_exp").css("color", "rgb(185,0,0)").css("font-size", "14px").text("The correct answer is: "+data.correct_answer)
        $(".answer_feedback").css("border-color", "rgba(236, 28, 28, 0.7)").css("-moz-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(238, 39, 2, 0.6)").css("-webkit-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(238, 39, 2, 0.6)").css("box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(238, 39, 2, 0.6)")
      $("#submit_exact").remove()
    $("#nextbutton").show()
  
  if options["start_countdown"]
    $.MB.Arena.start_countdown()
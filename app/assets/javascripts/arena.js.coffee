$.MB ||= {}

$.MB.init_arena = ->
  $.log("starting countdown")
  
  count_down_points = ->
    if $.points_remaining > 0 and $.continue_countdown == true
      $.points_remaining = $.points_remaining - 1
      $(".pointbarfiller").parent().find("div.pointbartext").text($.points_remaining + " points")
      $("#points_remaining").val($.points_remaining);
      setTimeout(count_down_points, 300)
    else
      $.continue_countdown = false

  count_down_bar = ->
    if $.continue_countdown == true
      $bar = $(".pointbarfiller")
      $.percent_remaining = $.percent_remaining - .1
      $bar.css("width", $.percent_remaining+"%")
      setTimeout(count_down_bar, 30)
  
  $.continue_countdown = true
  $.percent_remaining = 100
  $.points_remaining = 100
  
  $(".answer_content").unbind();
  $("#challenge_form").unbind();
  
  $(".answer_content").on "click", ->
    $(this).css('background-color', '#C6C6DA')
    $.continue_countdown = false
    $(this).find("input").attr("checked", "checked")
    $("#challenge_form").submit()
    $(".answer_content").unbind()
  
  $("#challenge_form").on "ajax:success", (xhr, data) ->
    $("#answer_"+data.correct_answer).css("background-color", "rgba(104, 231, 104, 0.79)").css("color", "white")
    if data.correct_answer != data.supplied_answer
      $("#answer_"+data.supplied_answer).css("background-color", "#FF9999").css("color", "white")
    $("#nextbutton").show()
  
  setTimeout ->
    setTimeout(count_down_bar, 300)
    setTimeout(count_down_points, 300)
  ,1000
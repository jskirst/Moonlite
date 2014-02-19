class @Arena
  constructor: (@start_time, @time_limit, @feedback, @countdown) ->
    @end_time = @start_time + @time_limit

    @bar_element = $(".pointbarfiller")
    @points_element = $(".pointbarfiller").parent().find("div.pointbartext")
    @points_input = $("#points_remaining")
    
    @unbind_all()
    @bind_keyboard_shortcuts()
    @bind_answer_clicks()
    @bind_submit()
    @bind_submit_failure()
    @bind_submit_success()
    @start_countdown() if @countdown

  percentage_remaining: =>
    now = new Date().getTime();
    total_time = @end_time - @start_time
    seconds_elapsed = now - @start_time
    pr = ((@end_time - now) / total_time) * 100
    if pr < 0
      @continue_countdown = false
      return 0
    else
      return pr

  points_remaining: =>
    return Math.round(@percentage_remaining())

  unbind_all: =>
    $(".answer_content").unbind();
    $("#challenge_form").unbind();

  bind_answer_clicks: =>
    $(".answer_content").on "click", ->
      @continue_countdown = false
      $(".answer_content").css("cursor", "wait")
      $(this).css('background-color', '#C6C6DA')
      $(this).find("input").attr("checked", "checked")
      $("#challenge_form").submit()
      $(".answer_content").unbind()

  bind_submit: =>
    $("#challenge_form").on "submit", =>
      @continue_countdown = false
      return true

  bind_submit_failure: =>
    $("#challenge_form").on "ajax:error", (xhr, data) ->
      location.reload()

  bind_submit_success: =>
    $("#challenge_form").on "ajax:success", (xhr, data) =>
      task_type = $(".responsespace").data("type")
      if @feedback
        if task_type == 1
          if data.correct
            $(".match_status_text").css("font-size", "22px").css("color", "rgb(0, 206, 0)").css("margin-left", "12px").css("font-weight", "bold").text("Correct!")
            $(".answer_feedback").css("border-color", "rgba(3, 233, 12, 0.8)").css("-moz-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(0, 255, 41, 0.6)").css("-webkit-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(0, 255, 41, 0.6)").css("box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(0, 255, 41, 0.6)")
          else
            $(".match_status_text").css("font-size", "22px").css("color", "rgb(233, 0, 0);").css("margin-left", "12px").css("font-weight", "bold").text("Incorrect...")
            $(".match_status_exp").css("color", "rgb(185,0,0)").css("font-size", "14px").text("The correct answer is: "+data.correct_answer)
            $(".answer_feedback").css("border-color", "rgba(236, 28, 28, 0.7)").css("-moz-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(238, 39, 2, 0.6)").css("-webkit-box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(238, 39, 2, 0.6)").css("box-shadow", "inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(238, 39, 2, 0.6)")
          $("#submit_exact").remove()
        else if task_type == 2
          $(".answer_content").each ->
            if String($(this).data("answer")) == String(data.correct_answer)
              $(this).css("background-color", "rgba(104, 231, 104, 0.79)").css("color", "white")
            else if String($(this).data("answer")) == String(data.answer)
              $(this).css("background-color", "#FF9999").css("color", "white")
      $(".answer_content").css("cursor", "pointer") 
      $("#nextbutton").show()

  count_down_points: =>
    if @continue_countdown
      points = @points_remaining()  
      @points_element.text(points + " points")
      @points_input.val(points);
    else
      clearInterval(@count_down_points_interval) 

  count_down_bar: =>
    if @continue_countdown
      @bar_element.css("width", @percentage_remaining()+"%")
    else
      clearInterval(@count_down_bar_interval)
    
  start_countdown: =>
    @continue_countdown = true
    wait = Math.max((@start_time - (new Date().getTime())), 0)
    @start_countdown_timeout = setTimeout(=>
      @count_down_bar_interval = setInterval(@count_down_bar, 100)
      @count_down_points_interval = setInterval(@count_down_points, 300)
    , wait)
  
  bind_keyboard_shortcuts: ->
    $(document).unbind("keyup").keyup (event) ->
      if event.which == 49
        $(".answer_content[data-order=0]").trigger "click"
      else if event.which == 50
        $(".answer_content[data-order=1]").trigger "click"
      else if event.which == 51
        $(".answer_content[data-order=2]").trigger "click"
      else if event.which == 52
        $(".answer_content[data-order=3]").trigger "click"
      else if event.which == 13
        if $("#nextbutton:visible").length > 0
          $("#nextbutton:visible").trigger "click"
          Turbolinks.visit($("#nextbutton").attr("href"))
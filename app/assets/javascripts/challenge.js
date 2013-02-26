var streak_countdown;
var start_modal_countdown;

function set_answer_status(previously_correct){
  var $correct_status = $("#correct_status");
  if(previously_correct){
    $correct_status.css("color", "#6AAC2B").text("Correct!").animate({opacity: 0.0}, 10000);
  } else {
    $correct_status.css("color", "#C43C35").text("Incorrect").animate({opacity: 0.0}, 10000);
  }
}

function start_question_timer(){
  if(typeof $("#countdown_timer").data("running") == 'undefined' || $(this).data("running") == false) {
    $("#countdown_timer").data("running", true);
    clearInterval(streak_countdown);
    var count = 30;
    streak_countdown = setInterval(function(){
      if(count >= 10){
        $(".timer").html("00:"+count);
      } else {
        $(".timer").html("00:0"+count);
      }
      if(count<=0){
        $(".timer").removeClass("timer").addClass("expired-timer");
        $(".streak").animate({opacity: 0.25}, 250);
        $("#listless").val(false);
        clearInterval(streak_countdown);
      } count --;
    }, 1000);
  }
}

function get_youtube_id_from_link(youtube_link){
  if(!youtube_link){ return false }
  if(youtube_link.indexOf("youtu.be")>=0){
    var start_pos = youtube_link.indexOf("be/") + 3;
  } else {
    var start_pos = youtube_link.indexOf("v=") + 2;
  }
  var id_fragments = youtube_link.substring(start_pos).split("&");
  var id = id_fragments[0];
  return id;
}

function is_valid_youtube_id(youtube_id){
  //need to add regex varification of id characters
  return (youtube_id.length == 11);
}

function set_youtube_preview(youtube_link, preview_id){
  var youtube_id = get_youtube_id_from_link(youtube_link);
  var params = { allowScriptAccess: "always", wmode: "transparent" }
  var attr = { id: preview_id };
  swfobject.embedSWF("http://www.youtube.com/v/"+youtube_id+"?enablejsapi=1&playerapiid=ytplayer&version=3", preview_id, "320", "265", "8", null, null, params, attr);
}

function set_large_youtube_preview(youtube_link, preview_id){
  var youtube_id = get_youtube_id_from_link(youtube_link);
  var params = { allowScriptAccess: "always", wmode: "transparent" }
  var attr = { id: preview_id };
  swfobject.embedSWF("http://www.youtube.com/v/"+youtube_id+"?enablejsapi=1&playerapiid=ytplayer&version=3", preview_id, "544", "320", "8", null, null, params, attr);
}

function check_checkin_before_submit(){
  $("#checkin_button").click(function(){
    if($('#checkin').val() == "true"){
      $(this).removeClass('button-info').addClass('button-standard').text("Confirm");
      $('#checkin').val(false)  
    } else {
      $(this).removeClass('button-standard').addClass('button-info').text("Confirmed");
      $('#checkin').val(true)
    } 
  });
}

function check_text_before_submit(){
  $("#challenge_form").submit(function(){
    if($("#answer_input").val() != ""){
      $("#challenge_form").unbind("submit");
      $("#challenge_form").submit();
      $("#submit_button").attr("disabled","disabled");
      return true;
    } else {
      alert("Please enter an answer before submitting.");
      $("#submit_button").removeAttr("disabled");
      return false;
    }
  });
}

function check_youtube_before_submit(){
  $("#challenge_form").submit(function(){  
    $('body').data("needs_reload", false);
    var url = $("#answer_input").val();
    var youtube_id = get_youtube_id_from_link(url);
    if(is_valid_youtube_id(youtube_id)){
      $("#challenge_form").unbind("submit");
      $("#challenge_form").submit();
      $(".loading_image").show();
      $("#submit_button").attr("disabled","disabled");
      return true;
    } else {
      alert("Please provide a link to a valid Youtube video.");
      $("#submit_button").removeAttr("disabled");
      return false;
    }
  });
}

function check_image_before_submit(){
  $("#challenge_form").submit(function(){
    if($("#uploaded_object").val() != ""){ return true; }
    var url = $("#answer_input").val();
    is_valid_image(url, function(valid){
      if(valid == true){
        $("#challenge_form").unbind("submit");
        $("#challenge_form").submit();
        $(".loading_image").show();
        $("#submit_button").attr("disabled","disabled");
        return true;
      } else {
        alert("Please provide a link to a valid image.");
        $("#submit_button").removeAttr("disabled");
        return false;
      }
    });
    return false;
  });
}

function count_down_points(){
  var points = $count_down_points.text().replace(" points", "");
  points = parseInt(points);
  if(points > 0){
    points = points - 1;
    $count_down_points.text(points + " points");
    $("#points_remaining").val(points);
    if(continue_countdown == true){
      setTimeout(count_down_points, 300);
    }
  }
}

function count_down_bar(){
  if(continue_countdown == true){
    count_down_bar_width = count_down_bar_width - .1
    $count_down_bar.css("width", count_down_bar_width+"%")
    setTimeout(count_down_bar, 30);
  }
}
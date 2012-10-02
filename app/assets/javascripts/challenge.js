var streak_countdown;
var start_modal_countdown;

// function get_next_task(event, data){
  // unblock_form_submit($('#challenge_form'));
  // if(data.indexOf("Redirecting to results:") >= 0){
    // redirect_url = data.substring(data.indexOf(":")+1);
    // window.location = redirect_url;
  // } else if (data.errors){
    // alert("You have an error.");
  // } else {
    // $('body').data("needs_reload", false);
    // $("section#content").html(data);
    // $('#challenge_form').on('ajax:success', get_next_task);
//     
    // start_question_timer();
    // expose_help_button();
  // }
// }

function show_start_modal(){
  clearInterval(start_modal_countdown);
  $('#start_modal').modal({
    keyboard: true,
    backdrop: 'static',
    show: true
  });
  var count = parseInt($("#starting_timer").text());
  start_modal_countdown = setInterval(function(){
    $("#starting_timer").html("<strong>"+count+"</strong>");
    if(count==0){
      $('#start_modal').modal('hide');
      clearInterval(start_modal_countdown);
      start_question_timer();
      return;
    }count --;
  }, 1000);
}

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
  swfobject.embedSWF("http://www.youtube.com/v/"+youtube_id+"?enablejsapi=1&playerapiid=ytplayer&version=3", preview_id, "480", "295", "8", null, null, params, attr);
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
      return false;
    }
  });
}

function check_image_before_submit(){
  $("#challenge_form").submit(function(){
    $('body').data("needs_reload", false);
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
        unblock_form_submit($('#challenge_form'));
        return false;
      }
    });
    return false;
  });
}

$(document).ready(function() {
  var page_needs_reload = false;
  $('body').data("needs_reload", false);
  expose_help_button();
  
  if($("#help_modal").exists()){
    $("#help_button").click(function(){
      $('#help_modal').modal({ keyboard: true, backdrop: 'static', show: true });
      $("#help_close_button").click(function(){ $("#help_modal").modal("hide"); });
    });
  } else {
    $("#help_button").hide();
  }
  //$('#challenge_form').on('ajax:success', get_next_task);
});
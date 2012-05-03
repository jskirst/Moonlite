function set_answer_status(previously_correct){
  var $correct_status = $("#correct_status");
  if(previously_correct){
    $correct_status.css("color", "#6AAC2B").text("Correct!").animate({opacity: 0.0}, 10000);
  } else {
    $correct_status.css("color", "#C43C35").text("Incorrect").animate({opacity: 0.0}, 10000);
  }
}

function start_question_timer(){
	var count = 30;
  countdown = setInterval(function(){
    if(count >= 10){
      $(".timer").html("00:"+count);
    } else {
      $(".timer").html("00:0"+count);
    }
    
    if(count==0){
      $(".timer").removeClass("timer").addClass("expired-timer");
      $(".streak").animate({opacity: 0.25}, 250);
      $("#listless").val(false)
    }count --;
  }, 1000);
}

$(document).ready(function() {
  $('form').submit(function() {
    if(typeof jQuery.data(this, "disabledOnSubmit") == 'undefined') {
      jQuery.data(this, "disabledOnSubmit", { submited: true });
      $('input[type=submit], input[type=button]', this).each(function() {
        $(this).attr("disabled", "disabled");
      });
      return true;
    }
    else
    {
      return false;
    }
  });
});
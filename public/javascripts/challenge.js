var streak_countdown;
var start_modal_countdown;

function get_next_task(event, data){
	console.log("AND:");
	console.log($correct_modal);
  console.log("GETNEXTTASK");
  console.log(data);
  if(data.indexOf("Redirecting to results:") >= 0){
		data = data.split(":");
		redirect_url = data[1];
    window.location = redirect_url;
  } else if (data.errors){
    alert("You have an error.");
  } else {
    $("section#content").html(data);
    
		$('#challenge_form').submit(block_form_submit);
    $('#challenge_form').on('ajax:success', get_next_task);
		
		var $correct_modal = $("#correct_modal");
		if($correct_modal.length > 0){
			$correct_modal.modal({keyboard: true, show: true });
			$correct_modal.on('hidden', function(){ $(this).remove(); });
			setTimeout(function(){$correct_modal.modal('hide'); start_question_timer();},1000);
		} else {
			start_question_timer();
		}
  }
}

function show_start_modal(){
	clearInterval(start_modal_countdown);
	$('#start_modal').modal({
		keyboard: true,
		backdrop: 'static',
		show: true
	});
	var count = 10;
	start_modal_countdown = setInterval(function(){
		$("#starting_timer").html("<strong>00:0"+count+"</strong>");
		if(count==0){
			$('#start_modal').modal('hide');
			clearInterval(start_modal_countdown);
			start_question_timer();
			return;
		}count --;
	}, 1000);
}

function bind_change_name_form(){
	$('#change_name_form').submit(function(){
		if ($("#user_name").val() == ""){
			$(".form_errors").text("Username must be at least 3 letters.");
			return false;
		} else if ($("#user_catch_phrase").val() == ""){
			$(".form_errors").text("Motto must be at least 3 letters.");
			return false;
		} else {
			$("#user_name_in_header").text($("#user_name").val());
			$('#username_modal').modal('hide');
			show_start_modal();
		}
	});
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

$(document).ready(function() {
  $('form#challenge_form').submit(function() {
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
	
	if($("#help_modal").exists()){
		$("#help_button").click(function(){
			$('#help_modal').modal({ keyboard: true, backdrop: 'static', show: true });
			$("#help_close_button").click(function(){ $("#help_modal").modal("hide"); });
		});
	} else {
		$("#help_button").hide();
	}
  
	$('#challenge_form').on('ajax:success', get_next_task);
});
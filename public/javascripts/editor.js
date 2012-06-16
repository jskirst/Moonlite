/* Section Editing */
function close_section_container(btn){
  $(btn).parents('td:first').find('.section_questions_container').hide();
  $(btn).parents('td:first').find('.section_content_container').hide();
  $(btn).parents('td:first').find("hr").hide();
  $(btn).parents('td:first').find(".section_overview").slideDown();
  $(btn).parent('li').siblings('li').removeClass("active");
  $(btn).parent('li').addClass('active');
}

function bind_edit_section_questions(){
  $(this).unbind();
  $(this).on('ajax:success', function(event, data){
    var $row = $(this).parents("td.section:first");
    $row.find(".section_questions_container").hide().html(data).slideDown();
    display_section_questions($row);
  });
}

function display_section_questions($row){
  $row.find(".edit_section_overview_pill").parent().removeClass("active");
  $row.find(".edit_section_content_pill").parent().removeClass("active");
  $row.find(".edit_section_questions_pill").parent().addClass("active");
  $row.find('.section_questions_container').slideDown();
  $row.find('.section_content_container').hide();
  $row.find(".section_overview").hide();
  $row.find("hr").show();
}

function bind_edit_section_content(){
  $(this).unbind();
  $(this).on('ajax:success', function(event, data){
    var $row = $(this).parents("td.section:first");
    $row.find(".section_content_container").hide().html(data);
    display_section_content($row);
  });
}

function display_section_content($row){
  $row.find(".edit_section_overview_pill").parent().removeClass("active");
  $row.find(".edit_section_content_pill").parent().addClass("active");
  $row.find(".edit_section_questions_pill").parent().removeClass("active");
  $row.find('.section_questions_container').hide();
  $row.find('.section_content_container').slideDown();
  $row.find(".section_overview").hide();
  $row.find("hr").show();
}


/* Task Editing */
function clear_form(){
  $("#task_question").val("");
  $("#task_answer1").val("");
  $("#task_answer2").val("");
  $("#task_answer3").val("");
  $("#task_answer4").val("");
  $("#task_fib_answer").val("");
  $('.suggestions').find('p,ol').each(function(){ $(this).hide(); });
}

function bind_delete_task(obj){
  $(obj).unbind();
  $(obj).on('ajax:success',
    function(event, data){
      if(data.errors){
        $(obj).parents("td.task:first").prepend("<div class='alert-message error'>"+data.error+"</div>");
      } else if(data.success){
        $(obj).parents("td.task:first").html("<div class='alert-message success'>"+data.success+"</div>");
        $('.alert-message').fadeOut(3000);
      } else {
        alert("Unknown error occurred");
      }
    }
  );
}

function bind_edit_task(obj){
  $(obj).unbind();
  $(obj).on('ajax:success',
    function(event, data){
      var $row = $(this).parents("td.task:first");
      $row.children(".question_display").hide();
      $row.find(".edit_button").removeAttr("disabled");
      $row.append(data);
      bind_update_task($row.find("form:first"));
      bind_answer_suggestion($row.find(".correct_answer:first"));
    }
  );
}

function bind_update_task(obj){
  $(obj).unbind();
  $(obj).on('ajax:success',
    function(event, data){
      if(data.errors){
        $(this).parents("td.task:first").find(".alert-message").text(data.errors[0]).show();
      } else {
        var $row = $(obj).parents("td.task:first");
        $row.html(data);
        $row.find('.delete_button').each(function(){
          bind_delete_task(this);
        });
        $row.find('.edit_button').each(function(){
          bind_edit_task(this);
        });
      }
    }
  );
}

function bind_answer_suggestion(obj){
  var $answer = $(obj);
  var $suggestions = $answer.parents(".row:first").children(".suggestions:first");
  get_suggestions($answer, $suggestions);
  $answer.change(function(){
    bind_answer_suggestion(this);
  });
}

function add_new_task(event, data) {
  unblock_form_submit($(".new_task_form"));
  try {
    data = $.parseJSON(data);
    $(this).find(".new_task").find(".message_container").text(data.errors[0]).removeClass("success").addClass("error").show();
  } catch(e){
  $(this).find(".new_task").find(".message_container").text("Question added successfully.").removeClass("error").addClass("success").show();
    clear_form();
    $task_list = $(this).siblings(".task_list");
    var $new_question = $("<tr><td class='task'>"+data+"</td></tr>").prependTo($task_list);
    $task_list.find(".task:first").show();
    $(".alert-message").fadeOut(5000);
    var question_count = $("#question_counter").text(parseInt($("#question_counter").text())+1);
    bind_delete_task($new_question.find(".delete_button"));
    bind_edit_task($new_question.find(".edit_button"));
    $new_question.hover(
      function(){
        $(this).find('.edit_task_buttons').show();
        $(this).css("background-color", "whitesmoke");
      },
      function(){
        $(this).find('.edit_task_buttons').hide();
        $(this).css("background-color", "white");
      }
    );
  }
}

$(function(){
  $('.edit_section_questions_pill').each(bind_edit_section_questions);
  $('.edit_section_content_pill').each(bind_edit_section_content);
  $(".edit_path_settings_button, .editable").each(function(){
    $(this).click(function(){$('#settings_modal').modal({show: true, keyboard: true, static: true});});
  });
  $('.edit_caption_container').each(function(){
    $(this).hover(function(){ $(this).find("div").show(); }, function(){ $(this).find("div").hide(); });
  });
});

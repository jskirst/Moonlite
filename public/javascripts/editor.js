function clear_form(){
  $("#task_question").val("");
  $("#task_answer1").val("");
  $("#task_answer2").val("");
  $("#task_answer3").val("");
  $("#task_answer4").val("");
}

function bind_delete_task(obj){
  $(obj).on('ajax:success',
    function(event, data){
      if(data.errors){
        $(obj).parents("td").prepend("<div class='alert-message error'>"+data.error+"</div>");
      } else if(data.success){
        $(obj).parents("tr").replaceWith("<div class='alert-message success'>"+data.success+"</div>");
        $('.alert-message').fadeOut(3000);
      } else {
        alert("Unknown error occurred");
      }
    }
  );
}

function bind_edit_task(obj){
  $(obj).on('ajax:success',
    function(event, data){
      var $row = $(this).parents("td:first");
      $row.children(".question_display").hide();
      $row.find(".edit_button").removeAttr("disabled");
      $row.append(data);
      bind_update_task($row.find("form:first"));
      console.log($row);
      console.log($row.find(".correct_answer:first"));
      bind_answer_suggestion($row.find(".correct_answer:first"));
    }
  );
}

function bind_update_task(obj){
  $(obj).on('ajax:success',
    function(event, data){
      var $row = $(obj).parents("td");
      $row.html(data);
      $row.find('.delete_button').each(function(){
        bind_delete_task(this);
      });
      $row.find('.edit_button').each(function(){
        bind_edit_task(this);
      });
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
  $('.alert-message').remove();
  unblock_form_submit($("#new_task"));
  if(data.errors){
    $("#task_form").prepend("<div class='alert-message error'>"+data.errors[0]+"</div>");
  } else {
    $("#task_form").prepend("<div class='alert-message success'>Task added successfully.</div>");
    clear_form();
    var $new_question = $("<tr class='task'><td>"+data+"</td></tr>").prependTo("#task_list");
    $(".task:first").show();
    $(".alert-message").fadeOut(5000);
    var question_count = $("#question_counter").text(parseInt($("#question_counter").text())+1);
    bind_delete_task($new_question.find(".delete_button"));
    bind_edit_task($new_question.find(".edit_button"));
  }
}
function add_events(obj){
  if(obj){
    $(obj).find("p").dblclick(function(){ transform(this); });
    $(obj).hover(add_delete_button, remove_delete_button);
  } else {
    $("li").each(function(){
      $(this).dblclick(function(){ 
        $(obj).find("p").dblclick(function(){ transform(this); });
      });
      $(this).hover(add_delete_button, remove_delete_button);
    });
  }
}

function add_delete_button(){
  if($(this).find("span").length == 0){
    var $del_link = $("<span class='btn secondary delete'>Remove</span>").prependTo(this);
    $del_link.click(function(){
      var question_id = $(this).parent().attr("id");
      $("#"+question_id+"_input").remove();
      $(this).parent().remove();
    });
  }
}

function remove_delete_button(){
  $(this).find(".delete").remove();
}

function transform(obj){
  $obj = $(obj);
  if($obj.find("span").length > 0){ return; }
  
  var question_id = $obj.attr("id");
  var obj_class = ($obj.text().substring(0,1) == "Q") ? "question" : "answer";
  var value = $obj.text().substring(3);
  
  $obj.html("");
  $("<input type='text'/>").attr({"value": value, "class": obj_class}).appendTo($obj);
  $("<span>Okay</span>").attr({"onclick": "revert(true)", "class": "btn primary"}).appendTo($obj);
  $("<span>Cancel</span>").attr({"onclick": "revert(false)", "class": "btn secondary", "alt": value}).appendTo($obj);
}

function revert(save){
  $("li").find("p").each(function(){
    if($(this).find("span").length > 0){
      var val = save ? $(this).find("input").val() : $(this).find(".secondary").attr("alt");
      var prefix = $(this).find("input").hasClass("question") ? "Q" : "A";
      $(this).find("span").remove();
      $(this).html("<strong>"+prefix+":</strong> "+val);
    }
  });
}

function finished(error){
  $("#loading_status").find("img").remove();
  if(error){
    $("#loading_status").append("<span class='alert-message danger'>Error</span>");
  } else {
    $("#loading_status").append("<span class='alert-message success'>Finished</span>");
  }
}

function get_questions(paragraphs, paragraph_index, limit){
  if(paragraph_index >= limit || paragraphs[paragraph_index] == null){
    finished();return;
  }
  
  paragraph = paragraphs[paragraph_index];
  $.ajax(std_url, 
    {type: "POST",
    dataType: "text",
    data: { text: paragraph },
    success: function(resp){
      resp = $.parseJSON(resp).resp;
      console.log(resp);
      if(resp.output.length > 0){
        add_question_set(paragraph_index, resp.input, resp.output);
      }
      get_questions(paragraphs, paragraph_index + 1, limit);
    },
    error: function(resp){
      console.log(resp);
      get_questions(paragraphs, paragraph_index + 1, limit);
    }
  });
}

function add_question_set(paragraph_index, input, output){
  var question_set_id = "question_set_" + paragraph_index;
  var $question_set = new_question_set(question_set_id);
  $question_set.find("blockquote").text(input);
  
  for(question_index in output){
    q = output[question_index];
    if(q == ""){ break; }
    var question_id = question_set_id + "_" + question_index;
    
    var $new_input = new_input(question_id);
    $new_input.val(q.question+q.answer);
    
    var $new_question = new_question($question_set, question_id);
    $new_question.html("<p><strong>Q:</strong> "+q.question+"</p><p><strong>A:</strong> "+q.answer+".</p>");
    add_events($new_question);
  }
}

function new_question_set(question_set_id){
  var $question_set = $("<div class='question_set'><blockquote></blockquote><ul></ul></div>").appendTo("#questions");
  $question_set.attr("id", question_set_id);
  return $question_set;
}

function new_input(question_id){
  var name = "questions[" + question_id + "]";
  var id = question_id + "_input";
  var $new_input = $("<input type='hidden'/>").appendTo("#hidden_inputs");
  $new_input.attr("id", id).attr("name",name);
  return $new_input;
}

function new_question($question_set, question_id){
  var $new_q = $("<li></li>").appendTo($question_set.find("ul"));
  $new_q.attr("id", question_id);
  return $new_q;
}
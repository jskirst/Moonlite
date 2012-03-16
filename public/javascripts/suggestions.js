function get_first_open_answer(first_answer){
  var $answers = $(first_answer).parent().parent().parent().find("input");
  var open_answer = null;
  $answers.each(function(){
    if($(this).val() == ""){
      open_answer = $(this);
      return false;
    }
  });
  return open_answer;
}

function loading_status($suggestions, on){
  if(on){
    $suggestions.find("ol").hide();
    $suggestions.find(".found_message").hide();
    $suggestions.find(".not_found_message").hide();
    $suggestions.find("img.loading").show();
  } else {
    $suggestions.find("img.loading").hide();
  }
}

function get_suggestions($answer, $suggestions){
  var phrase = $answer.val();
  if(phrase==""){ return; }
  loading_status($suggestions, true);
  
  $.ajax({url: std_url+"tasks/"+phrase+"/suggest.json",
    type: "GET",
    dataType: "text",
    success: function(resp){
      loading_status($suggestions, false);
      phrases = $.parseJSON(resp).phrases;
      
      if(phrases.length > 0){
        $suggestions.find(".found_message").show();
        $list = $suggestions.find("ol");
        $list.find("li").remove();
        $list.show();
        
        for(phrase in phrases){
          if(phrase >= 10){return true};
          
          $("<li>"+phrases[phrase]+"</li>").appendTo($list).dblclick(function(){
            var phrase = $(this).text();
            var $open_answer = get_first_open_answer($answer);
            if($open_answer){ $open_answer.val(phrase); }
          });
        }
      } else {
        $suggestions.find("ol").hide();
        $suggestions.find(".found_message").hide();
        $suggestions.find(".not_found_message").show();
      }
    }
  });
}
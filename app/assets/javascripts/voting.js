function show_creative_list(){
  $('#creative_tasks_list').show();
  $('#knowledge_tasks_list').hide();
  $('.creative_link').addClass('underlined');
  $('.creative_link').siblings('a').removeClass('underlined');
}

function show_knowledge_list(){
  $('#knowledge_tasks_list').show();
  $('#creative_tasks_list').hide();
  $('.knowledge_link').addClass('underlined');
  $('.knowledge_link').siblings('a').removeClass('underlined');
}

$(function(){
  $(".vote_button").on("ajax:success",
    function(event, data){
      if(data.errors){
        alert(data.errors);
      } else {
        var $vote_counter = $(this).parents("li:first").children("div.vote_count");
        var votes = parseInt($vote_counter.text());
        if($(this).hasClass("primary")){
          $(this).removeClass("primary").addClass("secondary").text("Vote");
          $vote_counter.html("<span class='label notice' style='font-size: 16px;'>+"+(votes-1)+"</span>");
        } else if($(this).hasClass("secondary")){
          $(this).removeClass("secondary").addClass("primary").text("Voted");
          $vote_counter.html("<span class='label notice' style='font-size: 16px;'>+"+(votes+1)+"</span>");
        }
      }
    }
  );
});
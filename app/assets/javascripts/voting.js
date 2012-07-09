function show_creative_list(){
  console.log(this);
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
        console.log($(this).parents("li:first").children("div:last"));
        var $vote_counter = $(this).parents("li:first").children("div.vote_count");
        console.log($vote_counter);
        var votes = parseInt($vote_counter.text());
        console.log(votes);
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
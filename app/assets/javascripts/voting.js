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
        var $vote_counter = $(this).find("div.vote_count");
        console.log($vote_counter);
        var votes = parseInt($vote_counter.text());
        console.log(votes);
        if($(this).hasClass("primary")){
          $(this).removeClass("primary");
          $vote_counter.text(votes-1);
        } else {
          $(this).addClass("primary");
          $vote_counter.text(votes+1);
        }
      }
    }
  );
});
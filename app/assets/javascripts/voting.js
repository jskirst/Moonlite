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

function animate_point_change($target, addition, limit){
  var points = parseInt($target.text());
  if(points == limit || points <= 0 || points >= 100000){ return false; }
  points = points + addition;
  $target.text(points);
  window.setTimeout(function(){ animate_point_change($target, addition, limit) }, 3);
}

function init_voting(){
  $(".vote_button").on("ajax:success",
    function(event, data){
      if(data.errors){
        alert(data.errors);
      } else {
        var $vote_points = $(this).siblings("span:first");
        var points = parseInt($vote_points.text());
        if($(this).hasClass("btn-primary")){
          $(this).removeClass("btn-primary");
          animate_point_change($vote_points, -1, (points-50));
        } else {
          $(this).addClass("btn-primary");
          animate_point_change($vote_points, +1, (points+50));
        }
      }
    }
  );
}
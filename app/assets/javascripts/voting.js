function animate_point_change($target, addition, limit){
  var points = parseInt($target.text());
  if(points == limit || points <= 0 || points >= 100000){ return false; }
  points = points + addition;
  $target.text(points);
  window.setTimeout(function(){ animate_point_change($target, addition, limit) }, 3);
}

function init_voting(){
  $(".vote_button").on("click",
    function(event){
      var $vote_points = $(this).siblings("span.vote_points:first");
      var points = parseInt($vote_points.text());
      if($(this).hasClass("btn-info")){
        $(this).removeClass("btn-info");
        animate_point_change($vote_points, -1, (points-50));
      } else {
        $(this).addClass("btn-info");
        animate_point_change($vote_points, +1, (points+50));
      }
    }
  );
}
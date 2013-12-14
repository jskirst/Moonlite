var streak_countdown;
var start_modal_countdown;

function set_answer_status(previously_correct){
  var $correct_status = $("#correct_status");
  if(previously_correct){
    $correct_status.css("color", "#6AAC2B").text("Correct!").animate({opacity: 0.0}, 10000);
  } else {
    $correct_status.css("color", "#C43C35").text("Incorrect").animate({opacity: 0.0}, 10000);
  }
}

function get_youtube_id_from_link(youtube_link){
  if(!youtube_link){ return false }
  if(youtube_link.indexOf("youtu.be")>=0){
    var start_pos = youtube_link.indexOf("be/") + 3;
  } else {
    var start_pos = youtube_link.indexOf("v=") + 2;
  }
  var id_fragments = youtube_link.substring(start_pos).split("&");
  var id = id_fragments[0];
  return id;
}

function is_valid_youtube_id(youtube_id){
  //need to add regex varification of id characters
  return (youtube_id.length == 11);
}

function set_youtube_preview(youtube_link, preview_id){
  var youtube_id = get_youtube_id_from_link(youtube_link);
  var params = { allowScriptAccess: "always", wmode: "transparent" }
  var attr = { id: preview_id };
  swfobject.embedSWF("https://www.youtube.com/v/"+youtube_id+"?enablejsapi=1&playerapiid=ytplayer&version=3", preview_id, "320", "265", "8", null, null, params, attr);
}

function set_large_youtube_preview(youtube_link, preview_id){
  var youtube_id = get_youtube_id_from_link(youtube_link);
  var params = { allowScriptAccess: "always", wmode: "transparent" }
  var attr = { id: preview_id };
  swfobject.embedSWF("https://www.youtube.com/v/"+youtube_id+"?enablejsapi=1&playerapiid=ytplayer&version=3", preview_id, "544", "320", "8", null, null, params, attr);
}
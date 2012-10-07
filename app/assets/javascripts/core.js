$(function(){
  $("#image_url_input").change(function(){
    var link = $(this).val();
    $(".image_url_preview").attr("src", link);
    $("#image_url_preview").attr("src", link);
  });
});

$('#topbar').scrollSpy();
$('#topbar').dropdown();

function is_valid_image(url, callback){
  if (url == ""){
    callback(false);
  } else {
    $("<img>", {
      src: url,
      error: function() { callback(false) },
      load: function() { callback(true) }
    });
  }
}

$(function() {
    $('.hoverscroll').hoverscroll();
});

$(function(){
  $(".comments form").bind("ajax:success", function(xhr, data){
    $(this).parent().find("ul").append(data);
    $(this).find("textarea").val("");
  });
});
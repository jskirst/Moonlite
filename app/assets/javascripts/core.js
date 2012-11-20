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

function open_launchpad(){
  $('#launchpad').modal({
    keyboard: true,
    backdrop: 'static',
    show: true
  });
}

function close_button(){
  $(".modal_close").click(function(){ $(this).parents('.modal').modal('hide'); });
}

function show_persona_challenges(){
  $(".show_persona_select").on("ajax:success", function(xhr, data){
    $(".explorenewusercontent").fadeOut('fast', function(){
      $(this).replaceWith(data, function(){
        $(this).fadeIn();
      });
    });
  });
}

function open_comments(comment){
  var $comments = $(comment).parents('.postfooter').find('.comments')
  console.log("opening");
  console.log($comments);
  if($comments.is(":visible")){
    $comments.slideUp();
  } else {
    $comments.slideDown(); 
  }
}

$(function(){
  close_button();
  $(".comments form").bind("ajax:success", function(xhr, data){
    $(this).parent().find("ul").append(data);
    $(this).parent().find(".no_comments").hide();
    $(this).find("textarea").val("");
  });
  $('.hoverscroll').hoverscroll();
  
  $('#topbar').scrollSpy();
  $('#topbar').dropdown();
  
  $("#image_url_input").change(function(){
    var link = $(this).val();
    $(".image_url_preview").attr("src", link);
    $("#image_url_preview").attr("src", link);
  });
  
  $(".login_link").click(function(){
    console.log("Shoudl see");
    $("#login_modal").modal({ keyboard: true, backdrop: 'static', show: true });
  });
});
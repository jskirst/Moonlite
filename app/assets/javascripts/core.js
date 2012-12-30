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

function init_comments(){
  $(".comments form").bind("ajax:success", function(xhr, data){
    $(this).parent().find("ul").append(data);
    $(this).parent().find(".no_comments").hide();
    $(this).find("textarea").val("");
  });
}

function close_button(){
  $(".modal_close").click(function(){ $(this).parents('.modal').modal('hide'); });
}

function help_button(){
  $(".help_close").click(function(){ $(this).parents('.help_box').fadeOut(); });
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
  if($comments.is(":visible")){
    $comments.slideUp();
  } else {
    $comments.slideDown(); 
  }
}

function truncate(text, length, ellipsis) {
  // Set length and ellipsis to defaults if not defined
  if (typeof length == 'undefined') var length = 100;
  if (typeof ellipsis == 'undefined') var ellipsis = '...';
   
  // Return if the text is already lower than the cutoff
  if (text.length < length) return text;
   
  // Otherwise, check if the last character is a space.
  // If not, keep counting down from the last character
  // until we find a character that is a space
  for (var i = length-1; text.charAt(i) != ' '; i--) {
    length--;
  }
   
  // The for() loop ends when it finds a space, and the length var
  // has been updated so it doesn't cut in the middle of a word.
  return text.substr(0, length) + ellipsis;
}

$(function(){
  close_button();
  help_button();
  $('.hoverscroll').hoverscroll();
  
  $("#image_url_input").change(function(){
    var link = $(this).val();
    $(".image_url_preview").attr("src", link);
    $("#image_url_preview").attr("src", link);
  });
  
  $(".login_link").click(function(){
    $("#login_modal").modal({ keyboard: true, backdrop: 'static', show: true });
  });
});
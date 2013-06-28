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
    convert_links();
  });
}

function close_button(){
  $(".modal_close").click(function(){ $(this).parents('.modal').modal('hide'); });
}

function show_persona_challenges(){
  $(".show_persona_select").on("ajax:success", function(xhr, data){
    $(".explorenewusercontent").hide(0, function(){
      $(this).replaceWith(data, function(){
        $(this).show();
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

function init_iph(){
  if(iph_off == true){ return false }
  for(help_pop in all_help){
    if(viewed_help.indexOf(help_pop) < 0){
      $('#'+help_pop).popover({
        trigger: 'manual',
        placement: all_help[help_pop].placement,  
        template: '<div class="popover" data-id="'+help_pop+'"><div class="arrow"></div><div class="popover-inner"><div class="popover-content"><p></p></div><a class="popover-close"></a></div></div>',
        content: all_help[help_pop].content,            
      });
      $('#'+help_pop).popover('show');
    }
  }
  
  $(".popover-close").click(function(){
    var $popover = $(this).parents(".popover");
    $popover.fadeOut();
    $.ajax({ data: { id: $popover.attr("data-id") }, url: mark_help_read_url });
  });
}

// Code source: http://stackoverflow.com/questions/37684/how-to-replace-plain-urls-with-links
function convert_links(){
  var replacedText, replacePattern1, replacePattern2;
  $("pre").each(function(){
    //URLs starting with http://, https://, or ftp://
    replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
    replacedText = $(this).text().replace(replacePattern1, '<a href="$1" target="_blank">$1</a>');

    //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
    replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
    replacedText = replacedText.replace(replacePattern2, '$1<a href="http://$2" target="_blank">$2</a>');
    
    $(this).html(replacedText); 
  }) 
}

function mark_notifications_as_read(){
  $.ajax({ 
    type: "GET", 
    url: mark_read_url, 
    complete: function(){ 
      $("title").text($("title").text().replace(/\([0-9]+\)/,''));
      $(".notifications_bubble").remove();
    } 
  });
}

function ping(url){
  $.get(url);
}

function show_loading_icon(){
  if($.data(document.body, 'reload') == true){
    $("#page_loading").show();
    setTimeout("$('#page_loading').hide();", 6000);
  } else {
    $.log("reset load;");
  }
}

function bind_hovercard_links(){
  $("body").on("ajax:success", ".hovercard_link", function(jqXHR, data){
    $("body").append(data);
    $("#hover_card").modal({ keyboard: true, show: true, backdrop: true});
  });
}
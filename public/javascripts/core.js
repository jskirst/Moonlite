var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-28492737-1']);
_gaq.push(['_trackPageview']);

(function() {
var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

$(function(){
  $("#image_url_input").change(function(){
    var link = $(this).val();
    $(".image_url_preview").attr("src", link);
    $("#image_url_preview").attr("src", link);
  });
});

$('#topbar').scrollSpy();
$('#topbar').dropdown();

function block_form_submit(){
  if(typeof $(this).data("disabledOnSubmit") == 'undefined' || $(this).data("disabledOnSubmit") == false) {
    $(this).data("disabledOnSubmit", true);
    $('input[type=submit], input[type=button]', this).each(function() {
      $(this).attr("disabled", "disabled");
    });
    return true;
  } else {
    return false;
  }
}

function unblock_form_submit($form){
  $form.data("disabledOnSubmit", false);
  $('input[type=submit], input[type=button]').removeAttr("disabled");
}

function expose_help_button(){
  if($("#help_modal").exists()){
    $("#help_button").click(function(){
      $('#help_modal').modal({ keyboard: true, backdrop: 'static', show: true });
      $("#help_close_button").click(function(){ $("#help_modal").modal("hide"); });
    });
  } else {
    $("#help_button").hide();
  }
}

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
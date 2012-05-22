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
    console.log(link);
    $("#image_url_preview").attr("src", link);
  });
});

$('#topbar').scrollSpy();
$('#topbar').dropdown();

function block_form_submit(){
  console.log("BLOCKING");
  console.log($(this).data("disabledOnSubmit"));
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
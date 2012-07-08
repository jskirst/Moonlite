//= require jquery
//= require jquery_ujs
//= require_self
//= require_tree .

$(function(){
  $('.locked_challenge').removeAttr("href");
  $('.locked_challenge').click(function(){
    $('#locked_modal').modal({
       keyboard: true,
       backdrop: 'static',
       show: true
    });
  });
});

(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=276612745757646";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));
$.fn.exists = function(){return this.length>0;}

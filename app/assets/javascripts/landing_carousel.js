function landing_slide(where){  
  var item_width = $('.carousel ul li').outerWidth()*4 + 60;
  if(where == 'left'){  
    var left_indent = parseInt($('.carousel ul').css('left')) + item_width;  
  } else {  
    var left_indent = parseInt($('.carousel ul').css('left')) - item_width;  
  }
  $('.carousel ul:not(:animated)').animate({'left' : left_indent},1000,function(){  
      if(where == 'left'){  
          $('.carousel ul li:first').before($('.carousel ul li:last'));  
      }else{  
          $('.carousel ul li:last').after($('.carousel ul li:first'));  
      }  
      $('.carousel ul').css({'left' : '-218px'});  
  });
}


//options( 1 - ON , 0 - OFF)  
var challengeauto_slide = 0;  
    var challengehover_pause = 1;  
var challengekey_slide = 0;  

//speed of auto slide(  
var challengeauto_slide_seconds = 5000;  
/* IMPORTANT: i know the variable is called ...seconds but it's 
in milliseconds ( multiplied with 1000) '*/  

/*move the last list item before the first item. The purpose of this is 
if the user clicks to slide left he will be able to see the last item.*/  
$('#challengecarousel_ul li:first').before($('#challengecarousel_ul li:last'));  

//check if auto sliding is enabled  
if(challengeauto_slide == 1){  
    /*set the interval (loop) to call function slide with option 'right' 
    and set the interval time to the variable we declared previously */  
    var challengetimer = setInterval('challengeslide("right")', challengeauto_slide_seconds);  

    /*and change the value of our hidden field that hold info about 
    the interval, setting it to the number of milliseconds we declared previously*/  
    $('#challengehidden_auto_slide_seconds').val(challengeauto_slide_seconds);  
}  

//check if hover pause is enabled  
if(challengehover_pause == 1){  
    //when hovered over the list  
    $('#challengecarousel_ul').hover(function(){  
        //stop the interval  
        clearInterval(timer)  
    },function(){  
        //and when mouseout start it again  
        timer = setInterval('challengeslide("right")', challengeauto_slide_seconds);  
    });  

}  

//check if key sliding is enabled  
if(challengekey_slide == 1){  

    //binding keypress function  
    $(document).bind('keypress', function(e) {  
        //keyCode for left arrow is 37 and for right it's 39 '  
        if(e.keyCode==37){  
                //initialize the slide to left function  
                challengeslide('left');  
        }else if(e.keyCode==39){  
                //initialize the slide to right function  
                challengeslide('right');  
              }  
          });  

      }  


  
//FUNCTIONS BELLOW  
  
//slide function

  
function challengeslide(where){  
  
            //get the item width  
            var item_width = $('#challengecarousel_ul li').outerWidth() + 24;  
  
            /* using a if statement and the where variable check 
            we will check where the user wants to slide (left or right)*/  
            if(where == 'left'){  
                //...calculating the new left indent of the unordered list (ul) for left sliding  
                var left_indent = parseInt($('#challengecarousel_ul').css('left')) + item_width;  
            }else{  
                //...calculating the new left indent of the unordered list (ul) for right sliding  
                var left_indent = parseInt($('#challengecarousel_ul').css('left')) - item_width;  
  
            }  
  
            //make the sliding effect using jQuery's animate function... '  
            $('#challengecarousel_ul:not(:animated)').animate({'left' : left_indent},500,function(){  
  
                /* when the animation finishes use the if statement again, and make an ilussion 
                of infinity by changing place of last or first item*/  
                if(where == 'left'){  
                    //...and if it slided to left we put the last item before the first item  
                    $('#challengecarousel_ul li:first').before($('#challengecarousel_ul li:last'));  
                }else{  
                    //...and if it slided to right we put the first item after the last item  
                    $('#challengecarousel_ul li:last').after($('#challengecarousel_ul li:first'));  
                }  
  
                //...and then just get back the default left indent  
                $('#challengecarousel_ul').css({'left' : '-224px'});  
            });  
  
}  

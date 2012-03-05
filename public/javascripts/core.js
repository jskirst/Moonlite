var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-28492737-1']);
_gaq.push(['_trackPageview']);

(function() {
var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

$('#topbar').scrollSpy();
$('#topbar').dropdown();

var youtube_entries = new Object();

function save(){
  $("#section_instructions").val($("#doc_root").html());
}

function add_events(){
  $("p,h2,h3,ol,ul,dl,div.thumb").each(function(){
    $(this).dblclick(function(){
      $(this).remove();
      save();
    });
  });
}

function get_article_id(topic){
  console.log("GETTING ARTICLE IDS");
  console.log(topic);
  topic = "article_"+topic.replace(/\s/g,"_");
  topic = topic.replace(/[^a-zA-Z0-9_]/g, "");
  return topic;
}

function add_empty_articles(topics){
  for(var t in topics){
    var topic = topics[t];
    var article_id = get_article_id(topic);
    var new_section = "<section class='wiki' id='"+article_id+"'><h1>"+topic+"</h1></section>";
    $("#articles").append(new_section);
  }
  save();
}

function change_youtube_video(obj, direction){
  current_youtube_entry = current_youtube_entry + direction
  var topic = $(obj).attr("topic");
  set_youtube_video(topic, current_youtube_entry);
}

function set_youtube_video(topic, entry){
  console.log("ENTRY");
  console.log(entry);
  var article_id = get_article_id(topic);
  var entries = youtube_entries[topic];
  console.log("GETTING YOUTUBE VIDEO");
  console.log(entries);
  var entry = entries[current_youtube_entry];
  console.log(entry);
  var title = entry.title["$t"];
  var id = entry.id["$t"].split("/").pop();
  console.log(title);
  
  var yt_id = article_id + "_ytapiplayer";
  var new_youtube = "<div class='youtube'><span topic='"+topic+"' onclick='change_youtube_video(self, 1);'>Next</span><br><div id='"+yt_id+"'>Flash required.</div></div>";
  $("#"+article_id+" div.youtube").remove();
  $("#"+article_id).append(new_youtube);
  var attr = { id: yt_id };
  var params = { allowScriptAccess: "always" }
  swfobject.embedSWF("http://www.youtube.com/v/"+id+"?enablejsapi=1&playerapiid=ytplayer&version=3",yt_id, "425", "356", "8", null, null, params, attr);
  save();
}

function search_youtube(topic){
  var std_url = "http://gdata.youtube.com/feeds/api/videos?max-results=10&alt=json";
  var url = std_url + "&q="+topic;
  console.log(url);
  $.ajax({url: url, 
    type: "GET", 
    dataType: "jsonp",  
    success: function(resp){
      console.log("SEACHING YOUTUBE");
      console.log(resp);
      console.log("ADDING TO YOUTUBE ENTRIES");
      youtube_entries[topic] = resp.feed.entry;
      console.log(youtube_entries);
      current_youtube_entry = 0;
      set_youtube_video(topic,current_youtube_entry);
    }
  });
}

function search_wikipedia(topic, original_topic){
  var url = "http://en.wikipedia.org/w/api.php?format=json&action=parse&page="+topic;
  $.ajax({url: url, 
    type: "GET", 
    dataType: "jsonp",  
    success: function(resp){
      console.log("SEACHING WIKIPEDIA");
      console.log(resp);
      if(resp.error != null){return;}
      var data = resp.parse;
      var title = data.title;
      var content = data.text["*"];
      
      //console.log(content);
      $redirect = $(content).find("li:contains('redirect')");
      if($redirect[0] == null) {$redirect = $(content).find("li:contains('REDIRECT')")};
      if($redirect[0] != null){
        redirect_url = $redirect.find("a").attr("href");
        var new_topic = redirect_url.split("/").pop();
        console.log("Found redirect for topic '"+topic+"'. Redirecting to topic: "+new_topic);
        search_wikipedia(new_topic, topic);
        return;
      }
      
      content = $(content).find("table").remove().end();
      content = $(content).find("ul").remove().end();
      content = $(content).find("ol").remove().end();
      content = $(content).find(".reflist").remove().end();
      content = $(content).find("#References").remove().end();
      content = $(content).find("#External_links").remove().end();
      content = $(content).find("#See_also").remove().end();
      content = $(content).find("#Further_reading").remove().end();
      content = $(content).find(".editsection").remove().end();
      if (original_topic == null){
        var article_id = get_article_id(topic);
      } else {
        var article_id = get_article_id(original_topic);
      }
      console.log("TOPIC '"+topic+"' has article_id:"+article_id);
      var $article = $("#"+article_id);
      $article.append("<div class='wiki_content'></div>");
      $article.find("div.wiki_content").html(content);
      $article.find("div.wiki_content table").remove();
      $article.find("div.wiki_content a").each(function(){
        $(this).attr("href", "http://www.wikipedia.com"+$(this).attr("href"));
      });
      save();
      add_events();
    }
  });
}

function search_google_images(topics){}
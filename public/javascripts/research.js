
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
  topic = "article_"+topic.replace(/\s/g,"_");
  topic = topic.replace(/[^a-zA-Z0-9_]/g, "");
  return topic;
}

function add_empty_articles(topics){
  for(var t in topics){
    var topic = topics[t];
    var article_id = get_article_id(topic);
    var new_section = "<section class='wiki' id='"+article_id+"'><div><a onclick='edit_article(\""+article_id+"\");' class='btn primary' style='margin: 15px; float: right;'>Edit</a></div><div><h1>"+topic+"</h1></div></section>";
    $("#articles").append(new_section);
  }
  save();
}

function edit_article(article_id){
  topic = $("#"+article_id+" h1").text();
	display_settings_editor(topic, article_id);
}

function set_youtube_video(topic, current_position, article_id, youtube_link){
  if (article_id == null){
    var article_id = get_article_id(topic);
    var entries = youtube_entries[topic];
    console.log(entries);
    if(current_position >= entries.size){
      console.log("Out of videos for topic: "+topic);
      return false;
    }
    var entry = entries[current_position];
    var title = entry.title["$t"];
    if(title.length > 35){
      title = title.substring(0, 35) + "...";
    }
    var id = entry.id["$t"].split("/").pop();
  } else {
    var start_pos = youtube_link.indexOf("v=") + 2;
    var id_fragments = youtube_link.substring(start_pos).split("&");
    var id = id_fragments[0];
  }
  console.log(id);
  var yt_id = article_id + "_ytapiplayer";
  var new_youtube = "<div class='youtube'><h6>"+title+"</h6><strong style='float:right;' onclick='set_youtube_video(\""+topic+"\", "+(current_position+1)+");'>Next</strong><br><div id='"+yt_id+"'>Flash required.</div></div>";
  $("#"+article_id+" div.youtube").remove();
  var appended = $("#"+article_id+" h1").after(new_youtube);
  var attr = { id: yt_id };
  var params = { allowScriptAccess: "always", wmode: "transparent" }
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
      youtube_entries[topic] = resp.feed.entry;
      set_youtube_video(topic,0);
    }
  });
}

function search_wikipedia(topic, original_topic, article_id){
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
        search_wikipedia(new_topic, topic, article_id);
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
      
      if (article_id == null && original_topic != null){
        article_id = get_article_id(original_topic);
      } else if (article_id == null && original_topic == null){
        article_id = get_article_id(topic);
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

function update_settings(){
  console.log("UPDATING SETTINGS");
  var article_id = $("#last_article").val();
  var $article = $("#"+article_id);
  var youtube_active = $("#youtube_active").prop("checked");
  var youtube_url = $("#youtube_url").val();
  var wiki_active = $("#wiki_active").prop("checked");
  var wiki_url = $("#wiki_url").val();
  
  if(youtube_active == false){
    $article.find("div.youtube").remove();
  }if(wiki_active == false){
    $article.find("div.wiki_content").remove();
  }
  
  if(wiki_url != ""){
    var new_topic = wiki_url.split("/").pop();
    search_wikipedia(new_topic, null, article_id);
  }if(youtube_url != ""){
    set_youtube_video(null, 0, article_id, youtube_url);
  }
  
  save();
}

function display_settings_editor(title, article_id){
  var $settings_editor = $("#settings_editor");
  var $article = $("#"+article_id);
  
  var youtube_active = ($article.find("div.youtube")[0] != null ? true : false);
  var wiki_active = ($article.find("div.wiki_content")[0] != null ? true : false);
  $("#wiki_url").val("");
  $("#youtube_url").val("");
  
  $settings_editor.find("h3").text(title);
  $settings_editor.find("#youtube_active").prop("checked", youtube_active);
  $settings_editor.find("#wiki_active").prop("checked", wiki_active);
  $settings_editor.find("#last_article").val(article_id);
  
  $('#settings_editor').modal({
     keyboard: true,
     backdrop: 'static',
     show: true
   });
}
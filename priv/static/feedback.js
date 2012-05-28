// requires jQuery & Mustache
function listen_for_events(timestamp) {
  var t = '' +
    '<div class="feedback">' +
    '  <div class="from"><strong>From:</strong> {{ from }} </div>' +
    '  <div class="subject"><strong>Subject:</strong> {{ subject }} </div>' +
    '  <div class="timestamp"><strong>Time:</strong> {{ create_time }} </div>' +
    '  <div class="body">{{ body }} </div>' +
    '</div>';
  $.ajax("/feedback/update/"+timestamp, { success:
    function(data, code, xhr) {
      // add the new feedbacks to our list, then recurse
      for (var i=0; i < data.feedbacks.length; i++) {
        var f = data.feedbacks[i];
        // var t = $("#feedback-template").html();
        var html = Mustache.render(t, f);
        $("#feedback-list").append(html);
      }
      listen_for_events(data.timestamp);
    }
  });
}


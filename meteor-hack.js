if (Meteor.isClient) {
Session.set("els",[{title:"1"},{title:"2"}]);
Template.table.element = function(){
	console.log("wtf");
	for()
	return Session.get("els");
}
    var col, content, h, i, j, user, w;
//    console.log('jquery loaded (via assets/js/main.coffee)');
    content = '';
    w = 20;
    h = 20;
    user = 1;
    if (user === 1) {
      col = "#FF0";
    }
    if (user === 2) {
      col = "#F00";
    }
    i = 0;
    while (i < h) {
      content += "<tr>";
      j = 0;
      while (j < w) {
        content += "<td>" + i + "," + j + " </td>";
        j++;
      }
      content += "</tr>";
      i++;
    }
//    alert(content)
    $("#tb").html(content);
    return $("td").click(function() {
      return $(this).css("background", col);
    });
  };


if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}

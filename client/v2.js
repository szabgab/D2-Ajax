function delete_item() {
    var id = $(this).attr('data-id');
    jQuery.ajax({
        url: 'http://127.0.0.1:5000/api/v2/item/' + id,
        type: 'DELETE',
        success: function(data) {
            show_items();
        }
    });
}

function show_items() {
    jQuery.get('http://127.0.0.1:5000/api/v2/items', function(data) {
        var i, html;
        html  = '<ul>';
        console.log(data);
        for (i = 0; i < data["items"].length; i++) {
            html += '<li>' + data["items"][i]["text"] + '<button class="delete" data-id="' +  data["items"][i]["_id"]["$oid"]  + '">x</a></li>';
        }
        html += '</ul>';
        $("#items").html(html);
        $(".delete").click(delete_item);
    });
}

$(document).ready(function() {
    jQuery.get('http://127.0.0.1:5000/api/v2/greeting', function(data) {
        console.log(data);
        $("#msg").html(data["text"]);
    });
    show_items();

    $("#reverse").click(function() {
        var str = $("#str").val();
        jQuery.get('http://127.0.0.1:5000/api/v2/reverse?str=' + str , function(data) {
            console.log(data);
            $("#msg").html(data["text"]);
        });
       return false;
    });

    $("#add-item").click(function() {
        var text = $("#text").val();
        jQuery.post('http://127.0.0.1:5000/api/v2/item', { text: text } , function(data) {
            console.log(data);
            if (data["error"]) {
                $("#msg").html('Error: ' + data["error"]);
            }
            if (data["ok"]) {
                $("#msg").html('Item ' + data["text"] + ' added');
            }
            show_items();

        });
       return false;
    });

});

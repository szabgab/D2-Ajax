var items;

function delete_item() {
    var id = $(this).attr('data-id');
    jQuery.ajax({
        url: 'http://127.0.0.1:5000/api/v2/item/' + id,
        type: 'DELETE',
        success: function(data) {
            var j;
            for ( j = 0; j < items["items"].length; j++) {
                if (items["items"][j]["_id"]["$oid"] === id) {
                    items["items"].splice(j, 1)
                    break;
                }
            }
            show_items();
        }
    });
}

function get_items() {
    jQuery.get('http://127.0.0.1:5000/api/v2/items', function(data) {
        items = data;
        show_items();
    });
}

function get_item(id) {
    jQuery.get('http://127.0.0.1:5000/api/v2/item/' + id , function(data) {
        items["items"].push(data["item"]);
        show_items();
    });
}

function show_items() {
    if (items === undefined) {
        get_items()
        return;
    }

    var i;
    console.log(items);
    var source   = document.getElementById('show-items-template').innerHTML;
    var template = Handlebars.compile(source);
    var html    = template({ data: items });

    $("#items").html(html);
    var cfg = {
        textExtraction: function(node) {
            var $node = $(node);
            var sort = $node.attr("sort");
            if (!sort) { return $node.text(); }
            if ($node.hasClass("date")) {
                return (new Date(sort)).getTime();
            } else {
                return sort;
            }
        }
    };
    $("#items-table").tablesorter(cfg);
    $(".delete").click(delete_item);
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
                get_item(data["id"]);
            }

        });
       return false;
    });

});

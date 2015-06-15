var items;

function routing(route) {
    if (! route) {
        route = '#';
    }
    console.log('route: ' + route);
    if (route === '#') {
        show_items();
        return;
    }
    var m = /^#id\/(\w+)$/.exec(route);
    if (m) {
        get_item(m[1]);
        //console.log(m[1]);
    }
}

function delete_item() {
    var id = $(this).attr('data-id');
    jQuery.ajax({
        url: 'http://127.0.0.1:5000/api/v3/item/' + id,
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
    jQuery.get('http://127.0.0.1:5000/api/v3/items', function(data) {
        items = data;
        show_items();
    });
}

function get_item(id) {
    jQuery.get('http://127.0.0.1:5000/api/v3/item/' + id , function(data) {
        show_item(data["item"]);
    });
}

function show_item(data) {
}

function show_items() {
    if (items === undefined) {
        get_items()
        return;
    }

    var i;
    console.log(items);
    _display('show-items-template', { data: items });


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
    $("#add-item").click(add_item);
}

function _display(template_name, data) {
    var source   = document.getElementById(template_name).innerHTML;
    var template = Handlebars.compile(source);
    var html    = template(data);

    $("#content").html(html);
    return;
}

function add_item() {
    var text = $("#text").val();
    jQuery.post('http://127.0.0.1:5000/api/v3/item', { text: text } , function(data) {
        console.log(data);
        if (data["error"]) {
            $("#msg").html('Error: ' + data["error"]);
        }
        if (data["ok"]) {
            items["items"].push( data["item"] );
            show_items();
            $("#msg").html('Item "' + data["item"]["text"] + '" added');
        }

    });
    return false;
};

$(document).ready(function() {
    $(window).bind('hashchange', function () {
		routing(window.location.hash);
	});
    routing(window.location.hash);
});

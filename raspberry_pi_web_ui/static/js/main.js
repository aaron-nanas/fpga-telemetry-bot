/***** Start of Button Section *****/
// Get the element with id="open_default_tab" and click on it
function initial_tab()
{
    document.getElementById("open_default_tab").click();
}

/***** Start of Drop-Down Menu Section *****/
function drop_down_event_listener()
{
    // Spatial Filter Event Listener
    const selected_spatial_filter = document.querySelector('.image-filter');
    const spatial_result = document.getElementById('return image spatial filter');

    selected_spatial_filter.addEventListener('change', (event) => {
    spatial_result.textContent = `${event.target.value}`;
    });
}

function toggle_push_button(input_from_pushbutton)
{
    var http_request_data = newXMLHttpRequest();
    http_request_data.open("GET", "/", true);
    http_request_data.send();
}
/***** End of Button Section *****/
function open_tab(current_event, tab_name) 
{
    var i, tab_content, tab_links;
    tab_content = document.getElementsByClassName("tab_content");

    for (i = 0; i < tab_content.length; i++) {
        tab_content[i].style.display = "none";
    }

    tab_links = document.getElementsByClassName("tab_links");
    for (i = 0; i < tab_links.length; i++) {
        tab_links[i].className = tab_links[i].className.replace(" active", "");
    }

    document.getElementById(tab_name).style.display = "block";
    current_event.currentTarget.className += " active";
}
/***** End of Drop-Down Menu Section *****/
initial_tab();
drop_down_event_listener();
$(function() {
    // $("#egg").hide();
    var count = 0;
    var showing = false;
    $("#dopamine-logo").on("click", function() {
        if (showing) {
            count = 0;
            showing = false;
            console.log("hiding");
            $("#egg").hide();
            $(".normal").show();
        } else if (count == 6) {
            showing = true;
            console.log("showing egg");
            $("#egg").show();
            $(".normal").hide();
        } else {
            console.log("incrementing count");
            count++;
        }
    });
});
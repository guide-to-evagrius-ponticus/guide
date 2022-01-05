$(".clip-after-line-1").click(function () {
    $(this).toggleClass("clip-after-line-1");
});
$("#cformtrigger").click(function() {
    $("#contact").toggle();
});
$(".hideNext").click(function () {
  $(this).toggleClass("hideNext");
  $(this).next().toggleClass("hidden");
});

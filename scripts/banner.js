// banner for Evagrius website
function fBanner () {
var evbanner = '<header>\
		<div class="masthead">\
            <figure class="toplogo">\
		        <img src="images/EvPontP923-290r-bw.gif" alt="miniature of Evagrius" height="100px" width="100px" />\
		        <figcaption>Paris. Gr. 923, fol. 290r</figcaption>\
		    </figure>\
            <h1 class="title">Guide to Evagrius Ponticus</h1>\
		    <h1 class="siteeditor">edited by Joel Kalvesmaki</h1>\
	        <h1 class="dateline">autumn 2016</h1>\
	    </div>\
    	<div class="nav">\
			<ul class="banner">\
				<li><a class="banner" href="index.htm">Introduction</a></li>\
				<li><a class="banner" href="life.htm">Life</a></li>\
				<li><a class="banner" href="corpus.htm">Writings</a></li>\
			</ul>\
		</div>\
    	<div class="nav">\
			<ul class="banner">\
				<li><a class="banner" href="images.htm">Images</a></li>\
				<li><a class="banner" href="bibliography.htm">Bibliography</a></li>\
				<li><a class="banner" href="about.htm">Credits</a></li>\
			</ul>\
		</div>\
	</header>\
    <hr />\
    ';
return evbanner;
}
function evfooter () {
var footer = '    <hr />\
<footer>\
	<div class="twitter">\
        <form action="http://groups.google.com/group/guide-to-evagrius-ponticus/boxsubscribe">\
            <input type="hidden" name="hl" value="en">\
            <input type="text" name="email" value="youremail@example.com">\
            <input type="submit" name="sub" value="Subscribe">\
        </form>\
    </div>\
    <p><a id="cformtrigger" href="#contact">feedback</a>&emsp;\
                <a href="about.htm">about</a>&emsp;\
                announcements: <a href="atom.xml">atom <img src="images/atom.png" alt="atom feed" /></a> |\
                <a href="https://twitter.com/GuidetoEvagrius">twitter <img src="images/twitter.gif" alt="twitter feed" /></a>\
                    | <a href="http://groups.google.com/group/guide-to-evagrius-ponticus?hl=en">email<\a>\
</p>\
                <div id="cform"><a id="contact"></a><form hidden="hidden"\
                    name="contactform" method="post" action="u2917bo.php">\
                    <input type="text" id="cformname" name="full_name" maxlength="60" size="30"\
                        value="Your name" />\
                    <input type="text" id="cformemail" name="email" maxlength="80" size="30"\
                        value="youremail@example.com" />\
                    <br /><textarea name="comments" id="cformcomm" maxlength="1000" cols="40" rows="2"></textarea>\
                    <br />Q. 2 + 9 = <input type="text" id="ccsum" name="csum" maxlength="10" size="4"></input><br /><input type="submit" value="send comments" />\
                </form>\
                </div>\
</footer>';
return footer;
}
function cformprep () {
    var winW = $(window).width();
    $("#cform").css("align","left");
    $("#cformname").attr("size",winW/50);
    $("#cformemail").attr("size",winW/50);
    $("#cformcomm").attr("cols",winW/25);
    $("#cformtrigger").click(function(){
        $("#cform > form").fadeIn();
        $("#cform > form > input:first-child").focus();
    });
}
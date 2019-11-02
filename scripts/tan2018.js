/* GLOBAL VARIABLES */
var glossIsBeingHovered = false, sourceGlossClass = "highlight0", targetGlossClasses =[ "highlight1", "highlight2"];

/* FUNCTIONS */
/* --general */

function comparePositions(p1, p2) {
    // Input: two arrays, each consisting of a pair of arrays, each with two numbers representing the X and Y limits of a div
    // Output: whether the two divs overlap
    if (p1 === undefined) {
        p1 =[0, 0];
    }
    if (p2 === undefined) {
        p2 =[1, 1];
    }
    return (isBetween(p1[0][0], p2[0]) || isBetween(p1[0][1], p2[0]) || isBetween(p2[0][0], p1[0])) && (isBetween(p1[1][0], p2[1]) || isBetween(p1[1][1], p2[1]) || isBetween(p2[1][0], p1[1]));
};

function filterArray(array, regExp) {
    var filtered =[];
    for (i = 0; i < array.length; i++) {
        if (regExp.test(array[i])) {
            filtered.push(array[i]);
        }
    }
    return filtered;
};

function getMaxOfArray(numArray) {
    return Math.max.apply(null, numArray);
};

function getPositions(elem) {
    // adapted from code courtesy @ŠimeVidas, http://stackoverflow.com/a/4230951
    var pos, width, height;
    pos = $(elem).offset();
    width = $(elem).width();
    height = $(elem).height();
    if (pos !== undefined) {
        return[[pos.left, pos.left + width],[pos.top, pos.top + height]]
    };
};

function getTextNodesUnder(el) {
    // code courtesy @Phrogz, http://stackoverflow.com/a/10730777
    var n, a =[], walk = document.createTreeWalker(el, NodeFilter.SHOW_TEXT, null, false);
    while (n = walk.nextNode()) a.push(n);
    return a;
}

function getTextWidth(text, font) {
    /* courtesy @Domi, http://stackoverflow.com/a/21015393 */
    // re-use canvas object for better performance
    var canvas = getTextWidth.canvas || (getTextWidth.canvas = document.createElement("canvas"));
    var context = canvas.getContext("2d");
    context.font = font;
    var metrics = context.measureText(text);
    return metrics.width;
}

function intersects(array1, array2) {
    var truthValue = false;
    for (i = 0; i < array1.length; i++) {
        for (j = 0; j < array2.length; j++) {
            if (array1[i] == array2[j]) {
                truthValue = true;
                break
            };
        };
    };
    return truthValue;
};

function isBetween(point, pair) {
    // Input: a number and an array of two numbers, with the smaller first
    // Output: a boolean indicating whether the point is between the pair, or identical to one of them
    return point >= pair[0] && point <= pair[1];
}

function maxLengthInStringArray(array, normSpace) {
    var a =[];
    for (var i = 0; i < array.length; i++) {
        thisText = array[i].textContent;
        thisTextNorm = normSpace ? normalizeSpace(thisText): thisText;
        a.push(thisTextNorm.length)
    }
    return Math.max(a, 1);
}

function normalizeSpace(string) {
    return string.replace(/\s+/g, " ")
}

function sum(array) {
    for (var i = 0; i < array.length; i++) {
        total += array[i] << 0;
    }
}

/* --specific to TAN class-2 files transformed to HTML */

function repositionTokClaims() {
    /*$(".align > .tok, .ana > .tok, .claim > * > .tok").each(function () {
    /\* process claims that affect tokens *\/
    var thisId = $(this).attr('id');
    var firstMatch = $('.idref--' + thisId).first();
    var lineHeight = firstMatch.height();
    var thisClaim = $(this).siblings().clone().wrapAll("<div style='bottom: " +(lineHeight * 1.0) + "' class='claim idref--" + thisId + "' />").parent();
    $(thisClaim).prependTo(firstMatch);
    /\*console.log(thisId, lineHeight);*\/
    });*/
    /*$(".claim .div-ref").each(function () {
    /\* process claims that affect divs *\/
    var thisId = $(this).parent().attr('id');
    var firstMatch = $('.idref--' + thisId).first();
    var thisClaim = $(this).parent().siblings().clone().wrapAll("<div class='claim idref--" + thisId + "' />").parent();
    $(thisClaim).appendTo(firstMatch);
    /\*console.log(thisId, lineHeight);*\/
    });*/
    $(".claim *[id], .align *[id], .ana *[id]").each(function () {
        /* go through each claim in a class 2 file, and place a copy in the class 1 dependencies */
        var thisId = $(this).attr('id');
        var firstMatch = $('.idref--' + thisId).first();
        var firstMatchIsDiv = $(firstMatch).hasClass('div');
        var thisClaim = $(this).parents('.claim, .align, .ana').first().clone().addClass('idref--' + thisId);
        /*if (firstMatchIsDiv) {
            $(thisClaim).insertAfter(firstMatch);
            $(firstMatch).next().find('#' + thisId).remove();
        } else {*/
            $(thisClaim).appendTo(firstMatch);
            $(firstMatch).find('#' + thisId).remove();
        /*};*/
        console.log(thisId, firstMatchIsDiv);
    });
    $(".div > .tok > *").each(function () {
        /* adjust claims so that they don't overlap */
        var prevClaim =[], bumpUpIncrement = 5;
        thisClaimPos = getPositions($(this));
        
        prevSiblingClaim = $(this).prevAll(".align, .ana, .claim").last();
        prevSiblingClaimPos = getPositions(prevSiblingClaim);
        prevSiblingClaimOverlap = comparePositions(thisClaimPos, prevSiblingClaimPos);
        
        prevClaim = $(this).parent().prevAll().find(".align, .ana, .claim").last();
        prevClaimPos = getPositions(prevClaim);
        prevClaimOverlap = comparePositions(thisClaimPos, prevClaimPos);
        
        while (prevClaimOverlap || prevSiblingClaimOverlap) {
            thisBottom = parseInt($(this).css("bottom"));
            $(this).css("bottom", thisBottom + bumpUpIncrement);
            thisClaimPos = getPositions($(this));
            prevSiblingClaimOverlap = comparePositions(thisClaimPos, prevSiblingClaimPos);
            prevClaimOverlap = comparePositions(thisClaimPos, prevClaimPos);
        }
    });
    $(function () {
    /* now set up claims, so that they can be color coded through hovering */
        $("div").hover(function () {
            theseClasses = $(this).attr('class').split(/\s+/);
            idrefClasses = filterArray(theseClasses, /^idref--/);
            for (var j = 0; j < idrefClasses.length; j++) {
                var thisClass = idrefClasses[j];
                $("." + thisClass).toggleClass("highlight" + j);
                /*console.log(j);*/
            };
            /*console.log(theseClasses);*/
        });
    });
};

/* --TAN-A-div */
$(function () {
    $(".sortable").sortable({
        stop: function (event, item) {
            updateSourceOrder(this);
        }
    });
    function updateSourceOrder(key) {
        srcKey = $(key).children('.head').children('.label');
        srcClasses =[];
        for (i = 0; i < srcKey.length; i++) {
            srcClasses.push(srcKey[i].innerHTML)
        };
        /*console.log(srcClasses);*/
        srcClasses.push('last');
        $('.div:has(.td), tr').each(function () {
            tdSort = $(this).children('div, td').sort(function (a, b) {
                aNorm = a.className.replace(/src--\d+/, '').replace(/.*src--(\S+).*/, '$1');
                bNorm = b.className.replace(/src--\d+/, '').replace(/.*src--(\S+).*/, '$1');
                var _aInd = srcClasses.indexOf(aNorm);
                var _bInd = srcClasses.indexOf(bNorm);
                if (_aInd < _bInd) {
                    return -1;
                } else if (_aInd > _bInd) {
                    return 1;
                } else {
                    return 0;
                }
            });
            /*console.log(srcKey, tdSort);*/
            $(tdSort).appendTo(this);
        });
    };
    $(".switch").click(function () {
        thisSrc = $(this).parent().children('.label').text();
        /*console.log(thisSrc);*/
        $("div.version.src--" + thisSrc).toggle();
        $("tr.src--" + thisSrc).toggle();
        $("td.src--" + thisSrc).toggle();
        $(this).children().toggle();
        $(this).parent().toggleClass('suppressed');
    });
});

/* --TAN-A-tok */


/* DOCUMENT HANDLING */

jQuery.fn.justtext = function () {
    return $(this).clone().children().remove().end().text();
};
$(".label").click(function () {
    $(this).nextAll().toggle("fast");
});
/*$("*:has(.item)").click(function () {
    $(this).children('.item').toggle("fast");
});*/
prepareDocument = function () {
    repositionTokClaims();
};

window.onload = prepareDocument;
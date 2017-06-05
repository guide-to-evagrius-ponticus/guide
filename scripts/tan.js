/* GLOBAL VARIABLES */
var glossIsBeingHovered = false, sourceGlossClass = "highlight0", targetGlossClasses =[ "highlight1", "highlight2"];

/* FUNCTIONS */
/* --general */

function comparePositions(p1, p2) {
    // Input: two arrays, each consisting of a pair of arrays, each with two numbers representing the X and Y limits of a div
    // Output: whether the two divs overlap
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
    return[[pos.left, pos.left + width],[pos.top, pos.top + height]];
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

function clearGlossMarks() {
    var glossClassSelector = "." + sourceGlossClass + ", ." + targetGlossClasses.join(", .");
    $(glossClassSelector).removeClass(sourceGlossClass + " " + targetGlossClasses.join(" "))
};

function markGlossMatches(elem, classRegExp,
sourceClassToToggle, targetClassesToToggle, toggleAttrCert) {
    // Input: any element, a regular expression, a string, an array of strings, a boolean
    // Output: the source element has a class toggled, and every element in the document that matches every nth class in the input document (those classes that match classRegExp) will have the nth targetClassesToToggle applied or removed, and attr-cert toggled, depending upon the boolean
    var rawClasses = elem.classList, theseClasses = filterArray(rawClasses, classRegExp),
    isTok = intersects([ "tok"], rawClasses);
    if (theseClasses.length < 1) {
        return
    };
    var sourceClass = isTok ? ".tok": ".gloss",
    targetClass = ! isTok ? ".tok": ".gloss",
    theseClassesSelector = "." + theseClasses.join(", .");
    allMatches = $(theseClassesSelector);
    if (toggleAttrCert) {
        $(allMatches).find(".attr-reuse-type").toggle();
    };
    var fellowSourceMatches = $(allMatches).filter(sourceClass),
    targetMatches = $(allMatches).filter(targetClass);
    $(fellowSourceMatches).each(function () {
        $(this).toggleClass(sourceClassToToggle);
    });
    for (i = 0; i < theseClasses.length; i++) {
        matchingElements = $(targetMatches).filter("." + theseClasses[i]);
        var whichClassToToggle = i % targetClassesToToggle.length;
        $(matchingElements).each(function () {
            $(this).toggleClass(targetClassesToToggle[whichClassToToggle]);
            if (toggleAttrCert) {
                $(this).children(theseClassesSelector).children(".attr-cert, .attr-reuse-type").toggle();
            };
        });
    };
    console.log(sourceClass, targetClass, theseClassesSelector, fellowSourceMatches, targetMatches);
};

function repositionGlosses() {
    var verticalKern = -12;
    var horizontalPadding = 4;
    $(".anchor").each(function () {
        var contextHeight = $(this).parent().height();
        var glosses = $(this).children();
        for (var i = 0, bottom = contextHeight + verticalKern; i < glosses.length; i++) {
            var thisGloss = glosses[i];
            var thisGlossStyle = window.getComputedStyle(thisGloss);
            var thisGlossTextNodes = getTextNodesUnder(thisGloss);
            var textNodeWidths = function () {
                var a =[];
                for (j = 0; j < thisGlossTextNodes.length; j++) {
                    thisTextItem = thisGlossTextNodes[j].textContent.replace(/\s+/g, " ");
                    thisWidth = getTextWidth(thisTextItem, thisGlossStyle.font);
                    a.push(thisWidth);
                };
                return a;
            };
            var maxTextWidth = Math.max.apply(Math, textNodeWidths());
            /*var thisGlossWithoutUnwantedNodes = $(thisGloss).clone().find('.attr-gloss, .f').remove().end();*/
            /*var thisGlossText = $(thisGloss).clone().children().remove().end().text();*/
            /*var thisGlossText = $(thisGloss).clone().find(':hidden').remove().end().text();*/
            /*var thisGlossText = $(thisGlossWithoutUnwantedNodes).text();
            var thisGlossTextNorm = thisGlossText.replace(/\s+/g, " ");
            var thisGlossTextWidth = getTextWidth(thisGlossTextNorm, thisGlossStyle.font);*/
            var thisNewWidth = maxTextWidth + horizontalPadding;
            var thisNewLeft = thisNewWidth * -0.5;
            $(thisGloss).css({
                "bottom": bottom, "left": thisNewLeft, "width": thisNewWidth
            });
            var thisNewHeight = $(thisGloss).height();
            bottom += thisNewHeight + 1;
            if (thisNewHeight > 200) {
                console.log(contextHeight, bottom, thisNewHeight)
            };
            /*console.log(thisGlossTextNodes.length, thisGlossTextNodes[1], thisGlossTextNorm, thisGlossTextWidth, thisNewLeft);*/
        };
        var childrenHeights = $(this).children().height();
        $(this).parent().css({
            "padding-top": Math.max(childrenHeights)
        });
    });
    var pass2divs = $(".TAN-T > .body > .div"), bumpUpIncrement = 5;
    for (var i = 0; i < pass2divs.length; i++) {
        var thisDiv = pass2divs[i];
        var theseGlosses = thisDiv.getElementsByClassName('gloss');
        for (var j = 1; j < theseGlosses.length; j++) {
            var thisGloss = theseGlosses[j], thisGlossPos = getPositions(thisGloss),
            thisGlossHeight = $(thisGloss).height();
            thisGlossAnchorParent = $(thisGloss).parent().parent(),
            thisGlossAnchorParentHeight = $(thisGlossAnchorParent[0]).height();
            for (var k = 0; k < j; k++) {
                var thisPrevGloss = theseGlosses[k], thisPrevGlossPos = getPositions(thisPrevGloss),
                theyOverlap = comparePositions(thisGlossPos, thisPrevGlossPos),
                thisGlossAnchorParentTopPadding = parseInt(thisGlossAnchorParent[0].style.paddingTop);
                while (theyOverlap) {
                    thisGlossBottom = parseInt(thisGloss.style.bottom);
                    thisGloss.style.bottom = thisGlossBottom + bumpUpIncrement;
                    if ((thisGlossBottom + thisGlossHeight) > (thisGlossAnchorParentHeight + thisGlossAnchorParentTopPadding)) {
                        thisGlossAnchorParentTopPadding += bumpUpIncrement;
                        thisGlossAnchorParent[0].style.paddingTop = thisGlossAnchorParentTopPadding;
                        //console.log(thisGlossAnchorParentTopPadding);
                    };
                    if (thisGlossBottom > 270) {
                        console.log(thisGlossAnchorParent[0], thisGlossAnchorParentTopPadding, thisGlossBottom);
                        console.log(thisGlossBottom, thisGlossHeight, thisGlossAnchorParentHeight, thisGlossAnchorParentTopPadding, thisGlossAnchorParent[0] !== null);
                        console.log((thisGlossBottom + thisGlossHeight) > (thisGlossAnchorParentHeight + thisGlossAnchorParentTopPadding));
                    };
                    /*console.log(thisGlossAnchorParentFullHeight, thisGlossBottom);*/
                    newGlossPos = getPositions(thisGloss);
                    newPrevGlossPos = getPositions(thisPrevGloss);
                    // console.log(newGlossPos, newPrevGlossPos);
                    theyOverlap = comparePositions(newGlossPos, newPrevGlossPos);
                };
                /*if (i > 3 && j > 5 && j < 8) {console.log(j, thisGloss.textContent, k, thisGlossPos, thisPrevGlossPos, theyOverlap);};*/
                /*if (j < 4) {
                console.log(j, k, thisGlossPos, thisPrevGlossPos, theyOverlap);
                }*/
            };
            /*console.log(thisGlossPos);*/
        };
        /*console.log(k < theseGlosses.length)*/
    };
};

/* DOCUMENT HANDLING */

jQuery.fn.justtext = function () {
    return $(this).clone().children().remove().end().text();
};
$(".label:not(td > div.topic > .label), .tei-label, table.claim thead, .attr-ref").click(function () {
    $(this).nextAll("*:not(.attr-src, .attr-ref)").toggle("fast");
});
$("td > div.topic > .label").click(function () {
    $(this).siblings("table").toggle("fast");
});
$(".tok, .gloss").hover(function () {
    if (glossIsBeingHovered) {
        clearGlossMarks();
    };
    markGlossMatches(this, /gloss\d+/, sourceGlossClass, targetGlossClasses, true);
    glossIsBeingHovered = true;
    /*console.log(this.classList);*/
},
function () {
    glossIsBeingHovered = false;
    clearGlossMarks();
});
$(".gloss:not(:has(.lm))").click(function () {
    // Only for glosses that do not have lexicomorphology content
    var thisGlossListRaw = this.classList,
    theseGlosses = filterArray(thisGlossListRaw, /gloss\d+/),
    theseGlossesSelector = "." + theseGlosses.join(", ."),
    currentTanT = $(this).parents(".TAN-T"),
    nextTanT = currentTanT.next(".TAN-T"),
    firstPrevTanT = currentTanT.prevAll(".TAN-T").last(),
    targetTanT = nextTanT.length > 0 ? nextTanT: firstPrevTanT,
    target = $(targetTanT).find(theseGlossesSelector),
    targetOffset = $(target).offset();
    window.scrollTo(0, targetOffset.top);
    $(target).toggleClass("lookatme");
    setTimeout(function () {
        $(target).toggleClass("lookatme");
    },
    800);
    console.log($(this).offset().top, target, targetOffset.top);
});
$(".m > .attr-orig-code").click(function () {
    // Only for clicks on morphological glosses
    $(this).nextAll(".f").each(function () {
        var explanatoryContent = $(this).children(".name");
        if (explanatoryContent.length < 1) {
            var fIdRef = "feature-" + $(this).children(".attr-which").text(),
            featureDef = document.getElementById(fIdRef),
            featureDefSubset = $(featureDef).children().clone();
            $(this).append(featureDefSubset);
            $(this).children(".name").first().css({
                "display": "block"
            });
            console.log(fIdRef, featureDef);
        };
    }).toggle();
    $(".f .name").click(function () {
        var nextHiddenSiblings = $(this).nextAll(":hidden"),
        nextVisibleSiblings = $(this).nextAll(":visible");
        if (nextVisibleSiblings.length > 1) {
            $(this).nextAll().hide("fast");
        } else {
            $(this).nextAll().show("fast");
        };
        //$(this).nextAll().toggle("fast");
        //console.log($(this).children());
    });
    $(".f .desc, .f .IRI").click(function () {
        $(this).toggle("fast");
    });
});
$("div[class ^= 'tok ref--']").click(function () {
    $(this).siblings().toggle("fast");
});
$(".object, .subject, .verb, .adverb, .where, .claimant").click(function () {
    var a = $(this);
    var atext = a.justtext().trim();
    var b = $("div:has(.name, .IRI)", this);
    if (b.length >= 1) {
        b.remove();
    } else {
        $(".attr-id:contains('" + atext + "')").filter(function () {
            return $(this).text() === atext;
        }).parent().clone().children("div:not(.name, .names, .desc, .descs, .IRI, .IRIs)").remove().end().appendTo(a);
    };
});

prepareDocument = function () {
    repositionGlosses();
    var test1 =[[213, 297],[977, 999]], test2 =[[259, 295],[977, 999]], test3 =[ 'apple', 'banana', 'cherry'], test4 =[ 'cherry'];
    /*console.log(isBetween(test1[0][0], test2[0]), comparePositions(test1, test2))*/
    /*console.log(filterArray(test3, /pp/));*/
    /*console.log(intersects(test3, test4));*/
};

window.onload = prepareDocument;

/* SCRAP */

/*$(".tok").hover(function () {
var theseRefs = $(this).attr("class").match(/ref-[-0-9a-zA-Z]+/);
if (theseRefs) {
theseRefs.forEach(function (cl) {
$("." + cl).toggleClass("refmatch")
});
};
var theseClasses = $(this).attr("class").split(' ');
for (var i = 0, thisClass; i < theseClasses.length; i++) {
thisClass = theseClasses[1]
};
/\*if (j) {
j.forEach(function (cl) {
if (cl.match(/gloss\d+/)) {
$("." + cl).toggleClass("highlight")
}
})
};*\/
});*/

/*function countLines(target) {
/\* courtesy @Jeff, http://stackoverflow.com/a/37623987/4572117 *\/
var style = window.getComputedStyle(target, null);
var height = parseInt(style.getPropertyValue("height"));
var fontSize = parseInt(style.getPropertyValue("font-size"));
var lineHeight = parseInt(style.getPropertyValue("line-height"));
var boxSizing = style.getPropertyValue("box-sizing");

if (isNaN(lineHeight)) lineHeight = fontSize * 1.2;

if (boxSizing == 'border-box') {
var paddingTop = parseInt(style.getPropertyValue("padding-top"));
var paddingBottom = parseInt(style.getPropertyValue("padding-bottom"));
var borderTop = parseInt(style.getPropertyValue("border-top-width"));
var borderBottom = parseInt(style.getPropertyValue("border-bottom-width"));
height = height - paddingTop - paddingBottom - borderTop - borderBottom
}
var lines = Math.ceil(height / lineHeight);
/\*alert("Lines: " + lines);*\/
return lines;
}*/

/*function comparePositions(p1, p2) {
// courtesy @ŠimeVidas, http://stackoverflow.com/a/4230951
var r1, r2;
r1 = p1[0] < p2[0] ? p1: p2;
r2 = p1[0] < p2[0] ? p2: p1;
return r1[1] > r2[0] || r1[0] === r2[0];
}*/
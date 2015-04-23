<?php

#    EasyPub: easy publication of RDF vocabulary
#    Copyright (C) 2009 Toby Inkster <mail@tobyinkster.co.uk>
#    Authors: Pierre-Antoine Champin <pchampin@liris.cnrs.fr>
#             Toby Inkster <mail@tobyinkster.co.uk>
#
#    EasyPub is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published
#    by the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    EasyPub is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with EasyPub.  If not, see <http://www.gnu.org/licenses/>.

/*
This is a drop-in PHP script for publishing RDF vocabulary.

Quick start
===========

Assuming you want to publish the vocabulary http://example.com/mydir/myvoc, the
reciepe with the most chances to work is the following:

1. Make `myvoc` a directory at a place where your HTTP server will serve it at
   the desired URI.
2. Copy the script in this directory as 'index.php'.
3. In the same directory, put two files named 'index.html' and 'index.rdf'

At this point, it may work (if you are lucky), or may have to tell your HTTP
server that the directory index (i.e. the file to serve for the bare directory)
is index.php.

In apache, this is done by creating (if not present) a `.htaccess` file in the
`myvoc` diractory, and adding the following line::
    DirectoryIndex index.php

Fortunately, this option is allowed to end-users by most webmasters.

More generaly
=============

The script will redirect, according to the Accept HTTP header, to a file with
the same name but a different extension. The file may have no extension at all,
so the following layout would work as well::

  mydir/myvoc (the script)
  mydir/myvoc.html
  mydir/myvoc.rdf

However, the tricky part is to convince the HTTP server to consider `myvoc` (an
extension-less file) as a PHP script (a thing in which I didn't succeed for the
moment...). The interesting feature of such a config is that it would support
"slash-based" vocabulary. For example, http://example.com/mydir/myvoc/MyTerm
would still redirect to the html or rdf file. This would not work with the reciep.
This would not work with the `index.php` recipe.

The script is can be configured to serve different files or support other mime
types by altering the `MAPPING` constant below.
*/

# the list below maps mime-types to redirection URL; %s is to be replaced by
# the script name (without its extension); note that the order may be
# significant (when matching */*)
$MAPPING = array(
    "text/html" => "%s.html",
    "application/rdf+xml" => "%s.rdf",
    ## uncomment the following if applicable
    # "application/xhtml+xml" => "%s.html",
    # "application/turtle" => "%s.ttl",
    # "text/n3" => "%s.n3",
);

$HTML_REDIRECT = <<<CHUNK
<html>
<head><title>Non-Information Resource</title></head>
<body>
<h1>Non-Information Resource</h1>
You should be redirected to <a href="%1\$s">%1\$s</a>.
</body>
</html>
CHUNK
;

$HTML_NOT_ACCEPTABLE = <<<CHUNK
<html>
<head><title>No acceptable representation</title></head>
<body>
<h1>No acceptable representation</h1>
This server has no representation of the required resource that is acceptable
by your web agent. Available representations are:<ul>
%s
</ul>
</body>
</html>
CHUNK
;

$HTML_REPRESENTATION = '<li><a href="%1$s">%1$s</a> (%2$s)</li>'."\n";

main($MAPPING, $HTML_REDIRECT, $HTML_NOT_ACCEPTABLE, $HTML_REPRESENTATION);

function main ($map, $h_redir, $h_unaccept, $h_rep)
{
    # Convert list of available MIME types into a string suitable for ConNeg class.
    $offers = array();
    foreach ($map as $mime => $file)
        $offers[] = $mime;
    $offers = implode(',' , $offers);
    
    $chosen = ConNeg::negotiate($offers);
    
    if (empty($chosen) || empty($map[$chosen]))
    {
        $representations = '';
        foreach ($map as $mime => $file)
            $representations .= sprintf($h_rep, $file, $mime);
        $msg = sprintf($h_unaccept, $representations);
        header("HTTP/1.1 406 Not Acceptable");
        header("Content-Type: text/html; charset=us-ascii");
        header("Content-Length: " . strlen($msg));
        print $msg;
        exit;
    }
    
    else
    {
        $filename = sprintf($map[$chosen], basename($_SERVER['SCRIPT_NAME'], '.php'));

        $goto = sprintf('%s://%s%s/%s',
            (empty($_SERVER['HTTPS']) ? 'http' : 'https'),          # protocol
            $_SERVER['SERVER_NAME']                                 # authority
                .($_SERVER['SERVER_PORT']==80?'':(':'.($_SERVER['SERVER_PORT']))),
            dirname($_SERVER['SCRIPT_NAME']),                       # directory
            $filename                                               # file
            );
        $msg = sprintf($h_redir, $goto);
        header("HTTP/1.1 303 See Other");
        header("Location: $goto");
        header("Content-Type: text/html; charset=us-ascii");
        header("Content-Length: " . strlen($msg));
        print $msg;
        exit;
    }
}

class ConNeg
{
    public static function negotiate ($offers, $accept=null, $death=false)
    {
        if (!isset($accept))
        {
            $accept = $_SERVER['HTTP_ACCEPT'];
            header('Vary: Accept');
        }
        
        $a_parsed = self::parse_accept($accept);
        $o_parsed = self::parse_accept($offers);
        
        $best = self::choose_offer($o_parsed, $a_parsed);
        
        if (!isset($best))
        {
            if (!$death)
                return self::offer_serialise($o_parsed[0]);
            
            header('HTTP/1.1 406 Not Acceptable');
            header('Content-Type: text/plain; charset=utf-8');
            print "Acceptable types would have been:\n\n";
            foreach ($o_parsed as $o)
                print self::offer_serialise($o) . "\n";
            exit;
        }
        
        return self::offer_serialise($best);
    }

    # logically a constant, but a function is easier to comment.
    public static function STANDARD_OFFERS()
    {
        return 'application/xhtml+xml; charset=utf-8; x-serialisation=html, '    # XHTML+RDFa
            .'text/html; charset=utf-8; q=0.9; x-serialisation=html, '                #     Equivalent to above (for now)
            .'application/rdf+xml; x-serialisation=xml, '                                # RDF/XML
            .'text/rdf; charset=utf-8; x-serialisation=xml, '                            #     Alias for above
            .'application/xml; q=0.9; x-serialisation=xml, '                            #     Equivalent to above (for now)
            .'text/xml; charset=utf-8; q=0.9; x-serialisation=xml, '                    #     Equivalent to above (for now)
            .'application/rss+xml; x-serialisation=rss, '                                # RSS 1.0 compatible RDF/XML
            .'application/turtle; x-serialisation=turtle, '                                # Turtle
            .'application/x-turtle; x-serialisation=turtle, '                            #     Alias for above
            .'text/turtle; charset=utf-8; x-serialisation=turtle, '                    #     Alias for above
            .'text/n3; charset=utf-8; q=0.9; x-serialisation=turtle, '                #     Equivalent to above (for now)
            .'text/rdf+n3; charset=utf-8; q=0.9; x-serialisation=turtle, '            #         Alias for above
            .'application/json; x-serialisation=json, '                                    # JSON
            .'application/x-json; x-serialisation=json, '                                #     Alias for above
            .'application/ecmascript; x-serialisation=js, '                                # Javascript
            .'application/javascript; x-serialisation=js, '                                #     Alias for above
            .'text/ecmascript; charset=utf-8; x-serialisation=js, '                    #     Alias for above
            .'text/javascript; charset=utf-8; x-serialisation=js, '                    #     Alias for above
            .'text/plain; charset=utf-8; x-serialisation=ntriples, '                    # N-Triples
            .'application/turtle; level=nt; x-serialisation=ntriples, '                #     Alias for above
            .'application/x-turtle; level=nt; x-serialisation=ntriples, '            #     Alias for above
            .'text/turtle; charset=utf-8; level=nt; x-serialisation=ntriples'        #     Alias for above            
            ; 
    }
    
    public static function serialisation ($fmt)
    {
        if (preg_match('/x-serialisation=([a-z]+)/i', $fmt, $matches))
        {
            return $matches[1];
        }

        return 'xml';
    }

    private static function offer_serialise ($o)
    {
        $rv = array($o['_type']);
        foreach ($o as $k => $v)
        {
            if ($k!='_type' && $k!='_position' && $k!='q')
                $rv[] = sprintf("%s=%s", $k, $v);
        }
        return implode('; ', $rv);
    }

    private static function parse_accept ($header)
    {
        $rv = array();
        $bits = preg_split('/\s*,\s*/', $header);
        for ($i=0; isset($bits[$i]); $i++)
        {
            $bit = trim($bits[$i]);
            
            $pieces = preg_split('/\s*;\s*/', $bit);
            $type   = strtolower(trim(array_shift($pieces)));
            $entry  = array('_position' => $i+1);
            
            foreach ($pieces as $piece)
            {
                list ($key, $val) = preg_split('/\s*\=\s*/', trim($piece));
                if (!isset($entry[ strtolower(trim($key)) ]))
                    $entry[ strtolower(trim($key)) ] = trim($val);
            }
            
            if (!isset($entry['q']) || $entry['q'] > 1.0)
                $entry['q'] = 1.0;
            
            $entry['_type'] = $type;
            $rv[] = $entry;
        }
        
        return $rv;
    }

    private static function choose_offer ($offers, $requests)
    {
        $offer_scores = array();
        
        foreach ($offers as $offer)
        {
            foreach ($requests as $request)
            {
                if (self::match_offer($offer, $request))
                {
                    $score = $offer;
                    $score['q'] *= $request['q'];
                    $score['_position'] *= $request['_position'];
                    
                    $offer_scores[] = $score;
                }
            }
        }
        
        usort($offer_scores, array(__CLASS__, 'score_sort'));
        
        return $offer_scores[0];
    }

    private static function score_sort ($a, $b)
    {
        if ((float)$a['q'] < (float)$b['q'])
            return 1;
        if ((float)$a['q'] > (float)$b['q'])
            return -1;
            
        if ($a['_position'] < $b['_position'])
            return -1;
        if ($a['_position'] > $b['_position'])
            return 1;
        
        return 0;
    }

    private static function match_offer ($o, $r)
    {
        # Content-Type - look for a mismatch
        list ($omaj, $omin) = explode('/', $o['_type']);
        list ($rmaj, $rmin) = explode('/', $r['_type']);
        if (!($omaj==$rmaj || $omaj=='*' || $rmaj=='*'))
            return false;
        if (!($omin==$rmin || $omin=='*' || $rmin=='*'))
            return false;
        
        # Content-Type Parameters - look for a mismatch
        foreach ($r as $rparam=>$rvalue)
        {
            if ($rparam != 'q' && $rparam != '_type' && $rparam != '_position')
            {
                if ($o[$rparam] != $rvalue)
                    return false;
                print "OK\n";
            }
        }
        
        # No mismatches.
        return true;
    }
}
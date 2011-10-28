<?php
/*****************************************************************************
 *
 * live.php - Standalone PHP script to serve the unix socket of the
 *            MKLivestatus NEB module as webservice.
 *
 * Copyright (c) 2010,2011 Lars Michelsen <lm@larsmichelsen.com>
 * Copyright (c) 2011 Benedikt Böhm <bb@xnull.de>
 *
 * License:
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * @AUTHOR   Lars Michelsen <lm@larsmichelsen.com>
 * @HOME     http://nagios.larsmichelsen.com/livestatusslave/
 * @VERSION  1.1
 *****************************************************************************/

/**
 * Script configuration.
 */

$conf = Array(
    // The socket type can be 'unix' for connecting with the unix socket or 'tcp'
    // to connect to a tcp socket.
    'socketType'       => 'unix',
    // When using a unix socket the path to the socket needs to be set
    'socketPath'       => '/var/nagios/rw/live',
    // When using a tcp socket the address and port needs to be set
    'socketAddress'    => '',
    'socketPort'       => '',
    // Modify the default allowed query type match regex
    'queryTypes'       => '(GET|COMMAND)',
);


###############################################################################
# Don't modify the code below when you're not aware of what you are doing...
###############################################################################

class LiveException extends Exception {}

$LIVE = null;

// Start the main function
livestatusSlave();

function livestatusSlave() {
    global $conf;

    try {
        verifyConfig();
        connectSocket();

        $query = getQuery();
        response(Array(0, 'OK'), queryLivestatus($query));

        closeSocket();
        exit(0);
    } catch(LiveException $e) {
        response(Array(1, $e->getMessage()), Array());
        closeSocket();
        exit(1);
    }
}

function readQuery() {
    global $argv;

    if (isset($_REQUEST['q']) && $_REQUEST['q'] !== '') {
        return str_replace('\\\\n', "\n", $_REQUEST['q']);
    } elseif (isset($argv[1]) && $argv[1] !== '') {
        return str_replace('\\n', "\n", $argv[1]);
    } else {
        throw new LiveException('No query given in "q" Attribute nor argv[0].');
    }
}

function getQuery() {
    global $conf;
    $query = readQuery();

    if (!preg_match("/^".$conf['queryTypes']."\s/", $query))
        throw new LiveException('Invalid livestatus query: ' . $query);

    return $query;
}

function response($head, $body) {
    header('Content-type: application/json');
    $json_result = json_encode(Array($head, $body));

    // Support jsonp when requested by client (see http://en.wikipedia.org/wiki/JSONP).
    if (isset($_REQUEST['callback']) && $_REQUEST['callback'] != '')
        $json_result = $_REQUEST['callback']."(".$json_result.")";

    echo $json_result;
}

function verifyConfig() {
    global $conf;

    if (!function_exists('socket_create')) {
        throw new LiveException('The PHP function socket_create is not available. Maybe the sockets module is missing in your PHP installation.');
    }

    if ($conf['socketType'] != 'tcp' && $conf['socketType'] != 'unix') {
        throw new LiveException('Socket Type is invalid. Need to be "unix" or "tcp".');
    }

    if ($conf['socketType'] == 'unix') {
        if ($conf['socketPath'] == '') {
            throw new LiveException('The option socketPath is empty.');
        }

        if (!file_exists($conf['socketPath'])) {
            throw new LiveException('The configured livestatus socket does not exists');
        }
    }

    elseif ($conf['socketType'] == 'tcp') {
        if ($conf['socketAddress'] == '') {
            throw new LiveException('The option socketAddress is empty.');
        }

        if ($conf['socketPort'] == '') {
            throw new LiveException('The option socketPort is empty.');
        }
    }
}

function readSocket($len) {
    global $LIVE;
    $offset = 0;
    $socketData = '';

    while($offset < $len) {
        if (($data = @socket_read($LIVE, $len - $offset)) === false)
            return false;

        $dataLen = strlen ($data);
        $offset += $dataLen;
        $socketData .= $data;

        if ($dataLen == 0)
            break;
    }

    return $socketData;
}

function queryLivestatus($query) {
    global $LIVE;

    // Query to get a json formated array back
    // Use fixed16 header
    socket_write($LIVE, $query . "OutputFormat: json\nResponseHeader: fixed16\n\n");
    socket_shutdown($LIVE, 1);

    if (substr($query, 0, 7) == "COMMAND") {
        return Array();
    }

    // Read 16 bytes to get the status code and body size
    $read = readSocket(16);

    if ($read === false)
        throw new LiveException('Problem while reading from socket: '.socket_strerror(socket_last_error($LIVE)));

    // Extract status code
    $status = substr($read, 0, 3);

    // Extract content length
    $len = intval(trim(substr($read, 4, 11)));

    // Read socket until end of data
    $read = readSocket($len);

    if ($read === false)
        throw new LiveException('Problem while reading from socket: '.socket_strerror(socket_last_error($LIVE)));

    // Catch errors (Like HTTP 200 is OK)
    if ($status != "200")
        throw new LiveException('Problem while reading from socket: '.$read);

    // Catch problems occured while reading? 104: Connection reset by peer
    if (socket_last_error($LIVE) == 104)
        throw new LiveException('Problem while reading from socket: '.socket_strerror(socket_last_error($LIVE)));

    // Decode the json response
    $obj = json_decode(utf8_encode($read));

    // json_decode returns null on syntax problems
    if ($obj === null)
        throw new LiveException('The response has an invalid format');
    else
        return $obj;
}

function connectSocket() {
    global $conf, $LIVE;

    // Create socket connection
    if ($conf['socketType'] === 'unix') {
        $LIVE = socket_create(AF_UNIX, SOCK_STREAM, 0);
    } elseif ($conf['socketType'] === 'tcp') {
        $LIVE = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    }

    if ($LIVE == false) {
        throw new LiveException('Could not create livestatus socket connection.');
    }

    // Connect to the socket
    if ($conf['socketType'] === 'unix') {
        $result = socket_connect($LIVE, $conf['socketPath']);
    } elseif ($conf['socketType'] === 'tcp') {
        $result = socket_connect($LIVE, $conf['socketAddress'], $conf['socketPort']);
    }

    if ($result == false) {
        throw new LiveException('Unable to connect to livestatus socket.');
    }

    // Maybe set some socket options
    if ($conf['socketType'] === 'tcp') {
        // Disable Nagle's Algorithm - Nagle's Algorithm is bad for brief protocols
        if (defined('TCP_NODELAY')) {
            socket_set_option($LIVE, SOL_TCP, TCP_NODELAY, 1);
        } else {
            // See http://bugs.php.net/bug.php?id=46360
            socket_set_option($LIVE, SOL_TCP, 1, 1);
        }
    }
}

function closeSocket() {
    global $LIVE;
    @socket_close($LIVE);
    $LIVE = null;
}

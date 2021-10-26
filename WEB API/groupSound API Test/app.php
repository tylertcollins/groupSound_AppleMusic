<?php

use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;
use MyApp\Socket;

require dirname( __FILE__ ) . '/vendor/autoload.php';

$wsServer = new WsServer(new Socket());

$server = IoServer::factory(
    new HttpServer(
        $wsServer
    ),
    3308
);

$loop = \React\EventLoop\Loop::get();

$wsServer->enableKeepAlive($loop, 15);
$server->run();
<?php

namespace MyApp;

use http\Client;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

class Socket implements MessageComponentInterface {

    public function __construct()
    {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn)
    {
        $this->clients->attach($conn);
        echo "New Connection! ({$conn->resourceId})\n";
    }

    public function onMessage(ConnectionInterface $from, $msg)
    {
        $data = json_decode($msg, true);

        switch ($data["type"]) {

            case "playlist_id":
                $connection = new SocketConnection($data["playlist_id"], $data["username"]);
                $this->clients->offsetSet($from, $connection);

                $event = new SocketEvent($data["session"], $connection, null);
                $event->handleEvent();

                echo "Connection established with {$from->resourceId} for {$data['playlist_id']}\n";

                $confirmation = array('type' => "event", 'event' => "connected", 'sender' => $data["username"]);
                $from->send(json_encode($confirmation));

                foreach ($this->clients as $client) {
                    if ($this->clients[$client]->playlist_id == $this->clients[$from]->playlist_id) {
                        $join = array('type' => "event", 'event' => "updateLog", 'logEvent'=>'joinedSession', 'sender' => $data["username"]);
                        $data["sender"] = $this->clients[$from]->username;
                        $client->send(json_encode($data));
                    }
                }
                break;

            case "event":
                $event = new SocketEvent($data["event"], $this->clients[$from], $data["options"]);
                $data["event"] = $event->handleEvent();
                $data["sender"] = $this->clients[$from]->username;

                if ($data["event"] != null) {
                    foreach ($this->clients as $client) {
                        if ($this->clients[$client]->playlist_id == $this->clients[$from]->playlist_id) {
                            if ($client->resourceId != $from->resourceId || $data["event"] == "skip") {
                                $client->send(json_encode($data));
                            }
                            $eventMessage = array('type'=>'event', 'event'=>'logUpdate', 'logEvent'=>$data["event"], 'sender'=>$data["sender"]);
                            $client->send(json_encode($eventMessage));
                        }
                    }
                }
                break;

            case "request":
                foreach ($this->clients as $client) {
                    if ($this->clients[$client]->playlist_id == $this->clients[$from]->playlist_id && $this->clients[$client]->isHost && $client->resourceId != $from->resourceId) {
                        $data["sender"] = $from->resourceId;
                        $client->send(json_encode($data));
                    }
                }
                break;

            case "message":
                foreach ($this->clients as $client) {
                    $encodedMessage = json_encode($data);
                    $from->send($encodedMessage);
                }
                break;

            case "response":
                foreach ($this->clients as $client) {
                    if ($this->clients[$client]->playlist_id == $this->clients[$from]->playlist_id && $client->resourceId == $data["requestFor"]) {
                        $data["sender"] = $from->resourceId;
                        $client->send(json_encode($data));
                    }
                }
                break;
        }
    }

    public function sendAll($message, $from) {
        foreach ($this->clients as $client) {
            if ($this->clients[$client]->playlist_id == $this->clients[$from]->playlist_id) {
                $client->send($message);
            }
        }
    }

    public function onClose(ConnectionInterface $conn)
    {
        if ($this->clients[$conn]->isHost) {
            $receivedEvent = new SocketEvent("endSession", $this->clients[$conn], null);
            $receivedEvent->handleEvent();

            foreach ($this->clients as $client) {
                if ($this->clients[$client]->playlist_id == $this->clients[$conn]->playlist_id) {
                    $endSessionEvent = array("type"=>"event", "event"=>"endSession", "sender"=>$this->clients[$conn]->username);
                    $client->send(json_encode($endSessionEvent));
                }
            }
        } else {
            $receivedEvent = new SocketEvent("leaveSession", $this->clients[$conn], null);
            $receivedEvent->handleEvent();

            foreach ($this->clients as $client) {
                if ($this->clients[$client]->playlist_id == $this->clients[$conn]->playlist_id) {
                    $leaveSessionEvent = array("type"=>"event", "event"=>"leaveSession", "sender"=>$this->clients[$conn]->username);
                    $client->send(json_encode($leaveSessionEvent));
                }
            }
        }

        $this->clients->detach($conn);
        echo "Connection Closed! ({$conn->resourceId})\n";
    }

    public function onError(ConnectionInterface $conn, \Exception $e)
    {
        //$conn->close();
        echo "Connection Error! ({$conn->resourceId}) for error: ({$e->getMessage()})\n";
    }

}
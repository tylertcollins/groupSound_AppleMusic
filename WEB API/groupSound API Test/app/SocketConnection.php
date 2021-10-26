<?php


namespace MyApp;

use Config\Database;
use PDO;

class SocketConnection
{

    public $conn;

    public $username;
    public $playlist_id;
    public $isHost;

    //DB Connection
    public function __construct($playlist, $user) {
        $this->playlist_id = $playlist;
        $this->username = $user;

        $database = new Database();
        $this->conn = $database->getConnection();
        $this->determineHost();
    }

    private function determineHost() {
        $sqlQuery = "SELECT host_username FROM playlists WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":playlist_id", $this->playlist_id);
        $stmt->execute();

        $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

        $this->isHost = $this->username == $dataRow["host_username"];
    }

}
<?php

namespace MyApp;

use Config\Database;
use PDO;

class SocketEvent {

    //Connection
    private $conn;

    private $socketEvent;
    private $socketConnection;

    private $socketOptions;

    public function __construct($event, $connection, $options) {
        $database = new Database();
        $this->conn = $database->getConnection();
        $this->socketEvent = $event;
        $this->socketConnection = $connection;
        $this->socketOptions = $options;
    }

    public function handleEvent() {
        switch ($this->socketEvent) {
            case "pause":
                $this->pause();
                return $this->socketEvent;
            case "play":
                $this->play();
                return $this->socketEvent;
            case "endSession":
                $this->endSession();
                return $this->socketEvent;
            case "leaveSession":
                $this->leaveSession();
                return $this->socketEvent;
            case "skip":
                return $this->socketEvent;
            case "skipVoteAdded":
                $this->addSkipVote();
                return $this->socketEvent;
            case "skipVoteRemoved":
                $this->removeSkipVote();
                return $this->socketEvent;
            case "like":
                // TODO
                return $this->socketEvent;
            case "rulesetUpdate":
                return $this->socketEvent;
            case "songQueueUpdate":
                return $this->socketEvent;
            case "nextSong":
                $this->nextTrack();
                return $this->socketEvent;
            case "pauseSuggest":
                // TODO
                return $this->socketEvent;
            case "inviteCodeUpdate":
                // TODO
                return $this->socketEvent;
            case "start":
                $this->start();
                return null;
            case "join":
                $this->join();
                return null;
        }
    }

    private function start() {
        $sqlQuery = "UPDATE playlists SET playback_status = \"playing\", active_listeners = 1, skip_count = 0 WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);

        $stmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);

        if (!$stmt) {
            echo $stmt->errorInfo();
        }

        if (!$stmt->execute()) {
            print_r($stmt->errorInfo());
        }
    }

    private function join() {
        $sqlQuery = "UPDATE playlists SET active_listeners = active_listeners + 1 WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);

        $stmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);

        if (!$stmt) {
            echo $stmt->errorInfo();
        }

        if (!$stmt->execute()) {
            print_r($stmt->errorInfo());
        }
    }

    private function pause() {
        $sqlQuery = "UPDATE playlists SET playback_status = \"paused\" WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $stmt->execute();
    }

    private function play() {
        $sqlQuery = "UPDATE playlists SET playback_status = \"playing\" WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $stmt->execute();
    }

    private function nextTrack() {
        $sqlQuery = "UPDATE playlists SET current_track = :track_id, skip_count = 0 WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $stmt->bindParam(":track_id", $this->socketOptions["track"]);
        $stmt->execute();
    }

    private function addSkipVote() {
        $sqlUpdateQuery = "UPDATE playlists SET skip_count = skip_count + 1 WHERE playlist_id = :playlist_id";
        $updateStmt = $this->conn->prepare($sqlUpdateQuery);
        $updateStmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $updateStmt->execute();

        $sqlSelectQuery = "SELECT playlists.skip_count, rulesets.skip_type, rulesets.skips_required 
        FROM playlists
        JOIN rulesets
        ON playlists.ruleset_id = rulesets.ruleset_id
        WHERE playlists.playlist_id = :playlist_id";
        $selectStmt = $this->conn->prepare($sqlSelectQuery);
        $selectStmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $selectStmt->execute();

        $dataRow = $selectStmt->fetch(PDO::FETCH_ASSOC);

        $skip_count = (int) $dataRow["skip_count"];
        $active_listeners = (int) $dataRow["active_listeners"];
        $skip_type = $dataRow["skip_type"];
        $skips_required = (int) $dataRow["skips_required"];

        switch ($skip_type) {
            case "value":
                if ($skip_count >= $skips_required) {
                    $this->socketEvent = "skip";
                }
                break;
            case "percent":
                $skips_required = $active_listeners * ($skips_required * 0.01);
                if ($skip_count >= $skips_required) {
                    $this->socketEvent = "skip";
                }
                break;
        }
    }

    private function removeSkipVote() {
        $sqlQuery = "UPDATE playlists SET skip_count = skip_count - 1 WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $stmt->execute();
    }

    private function leaveSession() {
        $sqlQuery = "UPDATE playlists SET skip_count = active_listeners - 1 WHERE playlist_id = :playlist_id";
        $updateStmt = $this->conn->prepare($sqlQuery);
        $updateStmt->bindParam(":playlist_id", $this->socketConnection->playlist_id);
        $updateStmt->execute();
    }

    private function endSession() {
        $sqlQuery = "UPDATE playlists SET playback_status = \"inactive\" WHERE playlist_id = :playlist_id";
        $stmt = $this->conn->prepare($sqlQuery);
        $stmt->bindParam("playlist_id", $this->socketConnection->playlist_id);
        $stmt->execute();
    }

}
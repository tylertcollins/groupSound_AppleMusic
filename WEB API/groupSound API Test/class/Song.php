<?php

namespace APIClass;

    use PDO;

    class Song {

        //Connection
        private $conn;

        //Table
        private $db_table = "songs";

        //Columns
        public $song_id;
        public $service_provider;
        public $song_title;
        public $song_artist;
        public $song_duration;
        public $is_explicit;

        //DB Connection
        public function __construct($db) {
            $this->conn = $db;
        }

        //GET ALL SONGS
        public function getAllSongs() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . "";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        //CREATE SONG
        public function createSong() {
            $sqlQuery = "INSERT INTO " . $this->db_table . " SET song_id = :song_id, service_provider = :service_provider, song_title = :song_title, song_artist = :song_artist, song_duration = :song_duration, is_explicit = :is_explicit";
            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->song_id=htmlspecialchars(strip_tags($this->song_id));
            $this->service_provider=htmlspecialchars(strip_tags($this->service_provider));
            $this->song_title=htmlspecialchars(strip_tags($this->song_title));
            $this->song_artist=htmlspecialchars(strip_tags($this->song_artist));
            $this->song_duration=htmlspecialchars(strip_tags($this->song_duration));

            //Bind Data
            $stmt->bindParam(":song_id", $this->song_id);
            $stmt->bindParam(":service_provider", $this->service_provider);
            $stmt->bindParam(":song_title", $this->song_title);
            $stmt->bindParam(":song_artist", $this->song_artist);
            $stmt->bindParam(":song_duration", $this->song_duration);
            $stmt->bindParam(":is_explicit", $this->is_explicit);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        public function verifySongWithPlaylistRuleset($ruleset, $playlist, $username) {

            $isValid = true;

            if (!$ruleset->allow_explicit && $this->is_explicit) {
                echo "Song cannot be explicit\n";
                $isValid = false;
            }

            if ($ruleset->song_min_duration > $this->song_duration) {
                echo "Song is too short\n";
                $isValid = false;
            }

            if ($ruleset->song_max_duration < $this->song_duration) {
                echo "Song is too long\n";
                $isValid = false;
            }

            if ($playlist->getPlaylistSongCount() + 1 > $ruleset->max_song_count) {
                echo "Playlist song limit reached\n";
                $isValid = false;
            }

            if ((int)$playlist->getUserPlaylistSongCount($username)->fetchColumn() + 1 > $ruleset->max_user_song_count) {
                echo "User song limit reached\n";
                $isValid = false;
            }

            return $isValid;
        }

        //READ SINGLE SONG
        public function getSong() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . " WHERE song_id = ? LIMIT 0,1";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->song_id);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->song_id = $dataRow["song_id"];
            $this->service_provider = $dataRow["service_provider"];
            $this->song_title = $dataRow["song_title"];
            $this->song_artist = $dataRow["song_artist"];
            $this->song_duration = $dataRow["song_duration"];
            $this->is_explicit = $dataRow["is_explicit"];
        }

        //UPDATE SONG
        public function updateSong() {
            $sqlQuery = "UPDATE " . $this->db_table . " SET service_provider = :service_provider, song_title = :song_title, song_artist = :song_artist, song_duration = :song_duration, is_explicit = :is_explicit, genre = :genre WHERE song_id = :song_id";
            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->song_id=htmlspecialchars(strip_tags($this->song_id));
            $this->service_provider=htmlspecialchars(strip_tags($this->service_provider));
            $this->song_title=htmlspecialchars(strip_tags($this->song_title));
            $this->song_artist=htmlspecialchars(strip_tags($this->song_artist));
            $this->song_duration=htmlspecialchars(strip_tags($this->song_duration));

            //Bind Data
            $stmt->bindParam(":song_id", $this->song_id);
            $stmt->bindParam(":service_provider", $this->service_provider);
            $stmt->bindParam(":song_title", $this->song_title);
            $stmt->bindParam(":song_artist", $this->song_artist);
            $stmt->bindParam(":song_duration", $this->song_duration);
            $stmt->bindParam(":is_explicit", $this->is_explicit);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        //DELETE SONG
        //TODO
        public function deleteSong() {
            $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE song_id = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->song_id);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }
    }
?>
<?php

namespace APIClass;

    use PDO;

    class Playlist {

        //Connection
        private $conn;

        //Table
        private $db_table = "playlists";
        private $user_playlist_table = "user_playlists";

        //Columns
        public $playlist_id;
        public $playlist_name;
        public $host_username;
        public $skip_count;
        public $ruleset_id;
        public $playlist_invite_code;
        public $last_updated;
        public $created_on;
        public $current_track;
        public $playback_status;

        //DB Connection
        public function __construct($db) {
            $this->conn = $db;
        }

        //GET ALL PLAYLISTS
        public function getAllPlaylists() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . "";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        //GET ALL USERS HOSTED PLAYLIST
        public function getUserHostPlaylists() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . " WHERE host_username = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->host_username);

            $stmt->execute();
            return $stmt;
        }

        public function getPlaylistSongCount() {
            $sqlQuery = "SELECT COUNT(*) FROM playlist_songs WHERE playlist_id = ?";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->bindParam(1, $this->playlist_id);
            $stmt->execute();
            return $stmt;
        }

        public function getUserPlaylistSongCount($username) {
            $sqlQuery = "SELECT COUNT(*) FROM playlist_songs WHERE playlist_id = :playlist_id, contributor_username = :contributor_username";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(":playlist_id", $this->playlist_id);
            $stmt->bindParam(":contributor_username", $username);

            $stmt->execute();
            return $stmt;
        }

        //CREATE PLAYLIST
        public function createPlaylist() {
            $sqlQuery = "INSERT INTO " . $this->db_table . " SET playlist_id = :playlist_id, playlist_name = :playlist_name, host_username = :host_username, ruleset_id = :ruleset_id, playlist_invite_code = :playlist_invite_code";
            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->playlist_name=htmlspecialchars(strip_tags($this->playlist_name));
            $this->host_username=htmlspecialchars(strip_tags($this->host_username));
            $this->ruleset_id=htmlspecialchars(strip_tags($this->ruleset_id));

            $this->playlist_id = $this->keygen();
            $this->playlist_invite_code = $this->inviteGen();

            //Bind Data
            $stmt->bindParam(":playlist_id", $this->playlist_id);
            $stmt->bindParam(":playlist_name", $this->playlist_name);
            $stmt->bindParam(":host_username", $this->host_username);
            $stmt->bindParam(":ruleset_id", $this->ruleset_id);
            $stmt->bindParam(":playlist_invite_code", $this->playlist_invite_code);

            $sqlQuery2 = "INSERT INTO " . $this->user_playlist_table . " SET username = :username, playlist_id = :playlist_id";
            $stmt2 = $this->conn->prepare($sqlQuery2);

            //Bind Data
            $stmt2->bindParam(":username", $this->host_username);
            $stmt2->bindParam(":playlist_id", $this->playlist_id);

            if ($stmt->execute() AND $stmt2->execute()) {
                return true;
            }

            return false;
        }

        function getPlaylistWithInviteCode() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . " WHERE playlist_invite_code = ? LIMIT 0,1";
            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->playlist_invite_code);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->playlist_id = $dataRow['playlist_id'];
            $this->playlist_name = $dataRow['playlist_name'];
            $this->host_username = $dataRow['host_username'];
            $this->ruleset_id = $dataRow["ruleset_id"];
            $this->skip_count = $dataRow["skip_count"];
        }

        //GET SINGLE PLAYLIST
        function getPlaylist() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . " WHERE playlist_id = ? LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->playlist_id);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->playlist_id = $dataRow['playlist_id'];
            $this->playlist_name = $dataRow['playlist_name'];
            $this->host_username = $dataRow['host_username'];
            $this->ruleset_id = $dataRow["ruleset_id"];
            $this->skip_count = $dataRow["skip_count"];
            $this->playlist_invite_code = $dataRow["playlist_invite_code"];
            $this->last_updated = $dataRow["last_updated"];
            $this->playback_status = $dataRow["playback_status"];
            $this->current_track = $dataRow["current_track"];
        }

        function getPlaylistPlaybackInfo() {
            $query = "SELECT playlists.current_track, playlist_songs.contributor_username, playlist_songs.skipped, playlist_songs.has_been_played, playlist_songs.date_added, songs.song_id, songs.song_title, songs.song_artist, songs.song_duration, songs.service_provider";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":playlist_id", $this->playlist_id);

            return $stmt->execute();
        }

        //UPDATE PLAYLIST
        public function updatePlaylist() {
            $sqlQuery = "UPDATE " . $this->db_table .  " SET playlist_name = :playlist_name, skip_count = :skip_count WHERE playlist_id = :playlist_id";

            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->playlist_name=htmlspecialchars(strip_tags($this->playlist_name));
            $this->playlist_id=htmlspecialchars(strip_tags($this->playlist_id));

            //Bind Data
            $stmt->bindParam(":playlist_name", $this->playlist_name);
            $stmt->bindParam(":playlist_id", $this->playlist_id);
            $stmt->bindParam(":skip_count", $this->skip_count);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        public function updateCurrentTrack() {
            $query = "UPDATE playlists SET current_track = :current_track WHERE playlist_id = :playlist_id";
            $stmt = $this->conn->prepare($query);

            $stmt->bindParam(":current_track", $this->current_track);
            $stmt->bindParam(":playlist_id", $this->playlist_id);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        //DELETE PLAYLIST
        public function deletePlaylist() {
            $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE playlist_id = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->playlist_id);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        // CREATE SEPARATE FILE
        function keygen($length = 25) {
            $key = '';
            list($usec, $sec) = explode(' ', microtime());
            mt_srand((float) $sec + ((float) $usec * 100000));

            $inputs = array_merge(range('z', 'a'), range(0,9), range('A', 'Z'));

            for ($i = 0; $i < $length; $i++) {
                $key .= $inputs[mt_rand(0, 61)];
            }

            return (string)$key;
        }

        function inviteGen($length = 10) {
            $key = '';
            list($usec, $sec) = explode(' ', microtime());
            mt_srand((float) $sec + ((float) $usec * 100000));

            $inputs = array_merge(range(0,9), range('A', 'Z'));

            for ($i = 0; $i < $length; $i++) {
                $key .= $inputs[mt_rand(0, 35)];
            }

            return (string)$key;
        }
    }
?>
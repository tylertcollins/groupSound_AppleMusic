<?php

namespace APIClass;

    use ArrayObject;
    use PDO;

    class PlaylistSong {

        //Connection
        private $conn;

        //Tables
        private $db_table = "playlist_songs";
        private $ruleset_table  = "rulesets";

        //Columns
        public $contributor_username;
        public $playlist_id;
        public $song_id;
        public $has_been_played;
        public $skipped;
        public $date_added;

        //DB Connection
        public function __construct($db) {
            $this->conn = $db;
        }

        //Add Song to Playlist
        function addSongToPlaylist() {
            $sqlQuery = "INSERT INTO " . $this->db_table . " SET playlist_id = :playlist_id, song_id = :song_id, contributor_username = :contributor_username, has_been_played = :has_been_played, date_added = :date_added";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(":playlist_id", $this->playlist_id);
            $stmt->bindParam(":song_id", $this->song_id);
            $stmt->bindParam(":contributor_username", $this->contributor_username);
            $stmt->bindParam(":has_been_played", $this->has_been_played);
            $stmt->bindParam(":date_added", $this->date_added);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        function removeSongFromPlaylist() {
            $sqlQuery = "DELETE FROM playlist_songs WHERE playlist_id = :playlist_id AND song_id = :song_id AND contributor_username = :contributor_username AND date_added = :date_added";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(":playlist_id", $this->playlist_id);
            $stmt->bindParam(":song_id", $this->song_id);
            $stmt->bindParam(":contributor_username", $this->contributor_username);
            $stmt->bindParam(":date_added", $this->date_added);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        //Get Playlist Songs
        public function getPlaylistSongs() {
            $sqlQuery = "SELECT playlist_songs.contributor_username, playlist_songs.skipped, playlist_songs.has_been_played, playlist_songs.date_added, songs.song_id, songs.song_title, songs.song_artist, songs.song_duration, songs.service_provider FROM " . $this->db_table . " INNER JOIN songs ON playlist_songs.song_id = songs.song_id WHERE playlist_songs.playlist_id = ? ORDER BY playlist_songs.date_added";
            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->playlist_id);

            $stmt->execute();
            return $stmt;
        }

        public function getPlaylistSongsTest() {
            $sqlQuery = "SELECT playlist_songs.contributor_username, playlist_songs.date_added, songs.song_id, songs.song_title, songs.song_artist, songs.song_duration, songs.service_provider FROM " . $this->db_table . " INNER JOIN songs ON playlist_songs.song_id = songs.song_id WHERE playlist_songs.playlist_id = ? ORDER BY playlist_songs.date_added";
            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->playlist_id);

            $stmt->execute();
            $this->orderSongs($stmt);
            return $stmt;
        }

        public function orderSongs($query)
        {

            //Sort song list by username and adding it to a hashmap (key: username, value: array of songs)
            $songMap = array();
            while ($row = $query->fetch(PDO::FETCH_OBJ)) {
                if (array_key_exists($row->contributor_username, $songMap)) {
                    array_push($songMap[$row->contributor_username], $row);
                } else {
                    $songMap[$row->contributor_username] = array($row);
                }
            }

            // Sort each mapped song array by date added - ASC order
            $maxSongCount = 0;
            foreach ($songMap as $value) {
                if (sizeof($value) > $maxSongCount) {
                    $maxSongCount = sizeof($value);
                }
            }

            //Convert each array to ArrayObject to allow for iteration
            foreach ($songMap as $key => $value) {
                $songMap[$key] = new ArrayObject($value);
            }

            // TODO: Figure out adding to ABC order while taking into account has been played tracks
//            $trackQueue = array();
//            $add_played_tracks = true;
//            while ($iterator_valid) {
//                $iterator_valid = false;
//                foreach ($songMap as $key => $value) {
//                    $iterator = $value->getIterator();
//                    if ($iterator->valid()) {
//                        if ($iterator->current()->has_been_played !== $add_played_tracks) {
//                            $iterator_valid = true;
//                            array_push($trackQueue, $iterator->current());
//                        }
//                    }
//                }
//            }

            // Create an array popping the first value from each user's array
            $songQueue = array();
            for ($x = 0; $x < $maxSongCount; $x++) {
                $songArray = array();
                foreach ($songMap as $key => $value) {
                    if ($value[$x] !== null) {
                        array_push($songArray, $value[$x]);
                    }
                }
                usort($songArray, array($this, "playlistSongSort"));
                $songQueue = array_merge($songQueue, $songArray);
            }

            return $songQueue;
        }

        public function isOrdered() {
            $sqlQuery = "SELECT rulesets.order_type FROM playlists INNER JOIN rulesets ON playlists.ruleset_id = rulesets.ruleset_id WHERE playlists.playlist_id = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(1, $this->playlist_id);

            $stmt->execute();
            $orderType = $stmt->fetch(PDO::FETCH_OBJ)->order_type;
            return $orderType;
        }

        public function playlistSongSort($a, $b) {
            return (strtotime($a->date_added) < strtotime($b->date_added)) ? -1 : 1;
        }

    }
<?php

namespace APIClass;

    class UserPlaylist {

        //Connection
        private $conn;

        //Table
        private $db_table = "user_playlists";

        //Columns
        public $username;
        public $playlist_id;

        //DB Connection
        public function __construct($db) {
            $this->conn = $db;
        }

        public function getUserPlaylists() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . " INNER JOIN playlists ON playlists.playlist_id = user_playlists.playlist_id WHERE user_playlists.username = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->username);

            $stmt->execute();
            return $stmt;
        }

        public function getUserPlaylistIDs() {
            $sqlQuery = "SELECT playlist_id FROM " . $this->db_table . " WHERE username = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->username);

            $stmt->execute();
            return $stmt;
        }

        public function getPlaylistUsers() {
            $sqlQuery = "SELECT username FROM " . $this->db_table . " WHERE playlist_id = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->playlist_id);

            $stmt->execute();
            return $stmt;
        }

        function addUserToPlaylist() {
            $sqlQuery = "INSERT INTO " . $this->db_table . " SET username = :username, playlist_id = :playlist_id";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(":username", $this->username);
            $stmt->bindParam(":playlist_id", $this->playlist_id);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

    }
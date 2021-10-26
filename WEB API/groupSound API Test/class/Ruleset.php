<?php

namespace APIClass;

    use PDO;

    class Ruleset {

        //Connection
        private $conn;

        //Table
        private $db_table = "rulesets";

        //Columns
        public $ruleset_id;
        public $skip_type;
        public $skips_required;
        public $order_type;
        public $allow_explicit;
        public $song_min_duration;
        public $song_max_duration;
        public $max_users;
        public $max_song_count;
        public $max_user_song_count;
        public $allow_repeats;
        public $max_songs_add;

        //DB Connection
        public function __construct($db) {
            $this->conn = $db;
        }

        public function getAllRulesets() {
            $sqlQuery = "SELECT * FROM " . $this->db_table;
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        public function getRuleset() {
            $sqlQuery = "SELECT * FROM " . $this->db_table . " WHERE ruleset_id = ? LIMIT 0,1";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->ruleset_id);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->ruleset_id = $dataRow['ruleset_id'];
            $this->skip_type = $dataRow['skip_type'];
            $this->skips_required = $dataRow['skips_required'];
            $this->order_type = $dataRow["order_type"];
            $this->allow_explicit = $dataRow["allow_explicit"];
            $this->song_min_duration = $dataRow['song_min_duration'];
            $this->song_max_duration = $dataRow['song_max_duration'];
            $this->max_users = $dataRow["max_users"];
            $this->max_song_count = $dataRow["max_song_count"];
            $this->max_user_song_count = $dataRow['max_user_song_count'];
            $this->allow_repeats = $dataRow['allow_repeats'];
            $this->max_songs_add = $dataRow["max_songs_add"];
        }

        public function createRuleset() {
            $sqlQuery = "INSERT INTO " . $this->db_table . " SET ";

            $this->ruleset_id = $this->keygen();
            $sqlQuery = $sqlQuery . "ruleset_id = :ruleset_id";

            if ($this->skip_type != null) {
                $sqlQuery = $sqlQuery . ", skip_type = :skip_type";
            }
            if ($this->skips_required != null) {
                $sqlQuery = $sqlQuery . ", skips_required = :skips_required";
            }
            if ($this->order_type != null) {
                $sqlQuery = $sqlQuery . ", order_type = :order_type";
            }
            if ($this->allow_explicit != null) {
                $sqlQuery = $sqlQuery . ", allow_explicit = :allow_explicit";
            }
            if ($this->song_min_duration != null) {
                $sqlQuery = $sqlQuery . ", song_min_duration = :song_min_duration";
            }
            if ($this->song_max_duration != null) {
                $sqlQuery = $sqlQuery . ", song_max_duration = :song_max_duration";
            }
            if ($this->max_users != null) {
                $sqlQuery = $sqlQuery . ", max_users = :max_users";
            }
            if ($this->max_song_count != null) {
                $sqlQuery = $sqlQuery . ", max_song_count = :max_song_count";
            }
            if ($this->max_user_song_count != null) {
                $sqlQuery = $sqlQuery . ", max_user_song_count = :max_user_song_count";
            }
            if ($this->allow_repeats != null) {
                $sqlQuery = $sqlQuery . ", allow_repeats = :allow_repeats";
            }
            if ($this->max_songs_add != null) {
                $sqlQuery = $sqlQuery . ", max_songs_add = :max_songs_add";
            }

            $stmt = $this->conn->prepare($sqlQuery);

            $stmt->bindParam(":ruleset_id", $this->ruleset_id);

            if ($this->skip_type != null) {
                $stmt->bindParam(":skip_type", $this->skip_type);
            }
            if ($this->skips_required != null) {
                $stmt->bindParam(":skips_required", $this->skips_required);
            }
            if ($this->order_type != null) {
                $stmt->bindParam(":order_type", $this->order_type);
            }
            if ($this->allow_explicit != null) {
                $stmt->bindParam(":allow_explicit", $this->allow_explicit);
            }
            if ($this->song_min_duration != null) {
                $stmt->bindParam(":song_min_duration", $this->song_min_duration);
            }
            if ($this->song_max_duration != null) {
                $stmt->bindParam(":song_max_duration", $this->song_max_duration);
            }
            if ($this->max_users != null) {
                $stmt->bindParam(":max_users", $this->max_users);
            }
            if ($this->max_song_count != null) {
                $stmt->bindParam(":max_song_count", $this->max_song_count);
            }
            if ($this->max_user_song_count != null) {
                $stmt->bindParam(":max_user_song_count", $this->max_user_song_count);
            }
            if ($this->allow_repeats != null) {
                $stmt->bindParam(":allow_repeats", $this->allow_repeats);
            }
            if ($this->max_songs_add != null) {
                $stmt->bindParam(":max_songs_add", $this->max_songs_add);
            }

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        public function deleteRuleset() {
            $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE ruleset_id = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->ruleset_id);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        function keygen($length = 25) {
            $key = '';
            list($usec, $sec) = explode(' ', microtime());
            mt_srand((float) $sec + ((float) $usec * 100000));

            $inputs = array_merge(range('z', 'a'), range(0,9), range('A', 'Z'));

            for ($i = 0; $i < $length; $i++) {
                $key .= $inputs[mt_rand(0, 61)];
            }

            return $key;
        }

    }
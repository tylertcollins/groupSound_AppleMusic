<?php

namespace APIClass;

    use PDO;

    class User
    {

        //Connection
        private $conn;

        //Table
        private $db_table = "users";

        //Columns
        public $username;
        public $user_display_name;
        public $email;
        public $password;

        //DB Connection
        public function __construct($db) {
            $this->conn = $db;
        }

        //GET ALL USERS
        public function getAllUsers()
        {
            $sqlQuery = "SELECT username, user_display_name, email FROM " . $this->db_table . "";
            $stmt = $this->conn->prepare($sqlQuery);
            $stmt->execute();
            return $stmt;
        }

        public function loginUser()
        {
            $sqlQuery = "SELECT username, user_display_name, email FROM " . $this->db_table . " WHERE username = :username AND password = :password";
            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->username = htmlspecialchars(strip_tags($this->username));
            $this->password = htmlspecialchars(strip_tags($this->password));

            //Bind Data
            $stmt->bindParam(":username", $this->username);
            $stmt->bindParam(":password", $this->password);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->username = $dataRow['username'];
            $this->user_display_name = $dataRow['user_display_name'];
            $this->email = $dataRow['email'];
        }

        //CREATE USER
        public function createUser()
        {
            $sqlQuery = "INSERT INTO " . $this->db_table . " SET username = :username, user_display_name = :user_display_name, email = :email, password = :password";
            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->username = htmlspecialchars(strip_tags($this->username));
            $this->user_display_name = htmlspecialchars(strip_tags($this->user_display_name));
            $this->email = htmlspecialchars(strip_tags($this->email));
            $this->password = htmlspecialchars(strip_tags($this->password));

            //Bind Data
            $stmt->bindParam(":username", $this->username);
            $stmt->bindParam(":user_display_name", $this->user_display_name);
            $stmt->bindParam(":email", $this->email);
            $stmt->bindParam(":password", $this->password);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        //GET USER USERNAME
        function getUser()
        {
            $sqlQuery = "SELECT username, user_display_name, email FROM " . $this->db_table . " WHERE username = ? LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->username);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->username = $dataRow['username'];
            $this->user_display_name = $dataRow['user_display_name'];
            $this->email = $dataRow['email'];
        }

        //GET USER EMAIL
        function getUserEmail()
        {
            $sqlQuery = "SELECT username FROM " . $this->db_table . " WHERE email = ? LIMIT 0,1";

            $stmt = $this->conn->prepare($sqlQuery);

            //Bind Data
            $stmt->bindParam(1, $this->email);

            $stmt->execute();

            $dataRow = $stmt->fetch(PDO::FETCH_ASSOC);

            $this->username = $dataRow['username'];
        }

        //UPDATE
        public function updateUser()
        {
            $sqlQuery = "UPDATE " . $this->db_table . " SET user_display_name = :user_display_name, email = :email WHERE username = :username";

            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->user_display_name = htmlspecialchars(strip_tags($this->user_display_name));
            $this->email = htmlspecialchars(strip_tags($this->email));
            $this->username = htmlspecialchars(strip_tags($this->username));

            //Bind Data
            $stmt->bindParam(":user_display_name", $this->user_display_name);
            $stmt->bindParam(":email", $this->email);
            $stmt->bindParam(":username", $this->username);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }

        //DELETE
        public function deleteUser()
        {
            $sqlQuery = "DELETE FROM " . $this->db_table . " WHERE username = ?";
            $stmt = $this->conn->prepare($sqlQuery);

            //Sanitize
            $this->username = htmlspecialchars(strip_tags($this->username));

            //Bind Data
            $stmt->bindParam(1, $this->username);

            if ($stmt->execute()) {
                return true;
            }

            return false;
        }
    }
?>
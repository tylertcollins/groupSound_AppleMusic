<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    include_once '../../config/Database.php';
    include_once '../../class/User.php';

    $database = new Database();
    $db = $database->getConnection();

    $items = new User($db);

    $stmt = $items->getAllUsers();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $userArray = array();
        $userArray["users"] = array();
        $userArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $user = array(
                "username" => $username,
                "user_display_name" => $user_display_name,
                "email" => $email
                );

            array_push($userArray["users"], $user);
        }

        echo json_encode($userArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>
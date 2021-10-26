<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../../config/Database.php';
    include_once '../../class/User.php';

    $database = new Database();
    $db = $database->getConnection();

    $item = new User($db);

    $item->username = isset($_GET['username']) ? $_GET['username'] : die();

    $item->getUser();

    if ($item->user_display_name != null) {

        $user = array(
            "username" => $item->username,
            "user_display_name" => $item->user_display_name,
            "email" => $item->email
        );

        http_response_code(200);
        echo json_encode($user);
    } else {
        http_response_code(404);
        echo json_encode("User not found.");
    }
?>

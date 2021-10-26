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

    $data = json_decode(file_get_contents("php://input"));

    $item->username = $data->username;
    $item->user_display_name = $data->user_display_name;
    $item->email = $data->email;

    if ($item->updateUser()) {
        echo json_encode("User data updated.");
    } else {
        echo json_encode("Data could not be updated.");
    }
?>
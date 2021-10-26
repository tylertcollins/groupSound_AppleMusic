<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    require "../../vendor/autoload.php";

    use APIClass\User;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $item = new User($db);

    $data = json_decode(file_get_contents("php://input"));

    $item->username = $data->username;
    $item->user_display_name = $data->user_display_name;
    $item->email = $data->email;
    $item->password = $data->password;

    if ($item->createUser()) {

        $user = array(
            "username" => $item->username,
            "user_display_name" => $item->user_display_name,
            "email" => $item->email
        );

        http_response_code(201);
        echo json_encode($user);
    } else {
        http_response_code(400);
        echo 'User could not be created.';
    }
?>
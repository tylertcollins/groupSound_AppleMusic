<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    require "../../vendor/autoload.php";

    use APIClass\User;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $item = new User($db);

    $data = json_decode(file_get_contents("php://input"));

    $item->username = $data->username;
    $item->password = $data->password;

    $item->loginUser();

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
        echo json_encode(
            array("message" => "Invalid user login.")
        );
    }
?>
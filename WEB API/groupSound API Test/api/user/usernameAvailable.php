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

    $item->username = isset($_GET['username']) ? $_GET['username'] : die();

    $item->getUser();

    if ($item->username != null) {
        http_response_code(404);
    } else {
        http_response_code(200);
    }
?>

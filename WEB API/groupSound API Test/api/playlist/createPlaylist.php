<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    require "../../vendor/autoload.php";

    use APIClass\Playlist;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $item = new Playlist($db);

    $data = json_decode(file_get_contents("php://input"));

    $item->playlist_name = $data->playlist_name;
    $item->host_username = $data->host_username;
    $item->ruleset_id = $data->ruleset_id;

    if ($item->createPlaylist()) {
        http_response_code(201);
        echo 'Playlist created successfully.';
    } else {
        http_response_code(400);
        echo 'Playlist could not be created.';
    }
?>
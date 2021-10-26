<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../../config/Database.php';
    include_once '../../class/Playlist.php';

    $database = new Database();
    $db = $database->getConnection();

    $item = new Playlist($db);

    $data = json_decode(file_get_contents("php://input"));

    $item->playlist_id = $data->playlist_id;
    $item->playlist_name = $data->playlist_name;
    $item->host_username = $data->host_username;
    $item->ruleset_id = $data->ruleset_id;
    $item->skip_count = $data->skip_count;

    if ($item->updatePlaylist()) {
        echo json_encode("Playlist data updated.");
    } else {
        echo json_encode("Data could not be updated.");
    }
?>
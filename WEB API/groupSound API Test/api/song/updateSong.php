<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../../config/Database.php';
    include_once '../../class/Song.php';

    $database = new Database();
    $db = $database->getConnection();

    $item = new Song($db);

    $data = json_decode(file_get_contents("php://input"));

    $item->song_id = $data->song_id;
    $item->service_provider = $data->service_provider;
    $item->song_title = $data->song_title;
    $item->song_artist = $data->song_artist;
    $item->song_duration = $data->song_duration;
    $item->is_explicit = $data->is_explicit;
    $item->genre = $data->genre;

    if ($item->updateSong()) {
        echo json_encode("Song data updated.");
    } else {
        echo json_encode("Data could not be updated.");
    }
?>
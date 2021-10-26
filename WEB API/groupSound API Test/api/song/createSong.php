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

    $song = new Song($db);

    $data = json_decode(file_get_contents("php://input"));

    $song->song_id = $data->song_id;
    $song->service_provider = $data->service_provider;
    $song->song_title = $data->song_title;
    $song->song_artist = $data->song_artist;
    $song->song_duration = $data->song_duration;
    $song->is_explicit = $data->is_explicit;
    $song->genre = $data->song_genre;

    if ($song->createSong()) {
        echo 'Song has been added successfully';
        http_response_code(201);
    } else {
        echo 'Song already exists in database';
        http_response_code(400);
    }
?>
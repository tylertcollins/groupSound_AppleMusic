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

    $item->song_id = isset($_GET['song_id']) ? $_GET['song_id'] : die();

    $item->getSong();

    if ($item->song_title != null) {

        $song = array(
            "song_id" => $item->song_id,
            "service_provider" => $item->service_provider,
            "song_title" => $item->song_title,
            "song_artist" => $item->song_artist,
            "song_duration" => $item->song_duration,
            "is_explicit" => $item->is_explicit,
            "genre" => $item->genre
        );

        http_response_code(200);
        echo json_encode($song);
    } else {
        http_response_code(404);
        echo json_encode("Song not found.");
    }
?>

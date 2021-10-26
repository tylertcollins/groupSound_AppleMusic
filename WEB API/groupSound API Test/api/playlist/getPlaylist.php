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

    $item = new playlist($db);

    $item->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();

    $item->getPlaylist();

    if ($item->playlist_name != null) {

        $playlist = array(
            "playlist_id" => $item->playlist_id,
            "host_username" => $item->host_username,
            "playlist_name" => $item->playlist_name,
            "ruleset_id" => $item->ruleset_id,
            "skip_count" => $item->skip_count,
            "invite_code" => $item->playlist_invite_code,
            "last_updated" => $item->last_updated,
            "playback_status" => $item->playback_status,
            "current_track" => $item->current_track
        );

        http_response_code(200);
        echo json_encode($playlist);
    } else {
        http_response_code(404);
        echo json_encode("Playlist not found.");
    }
?>

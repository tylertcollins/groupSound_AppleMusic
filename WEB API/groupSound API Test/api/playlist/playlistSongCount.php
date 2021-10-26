<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    include_once '../../config/Database.php';
    include_once '../../class/Playlist.php';

    $database = new Database();
    $db = $database->getConnection();

    $item = new Playlist($db);

    $item->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();

    $stmt = $item->getPlaylistSongCount();

    $songCount = $stmt->fetchColumn();

    if ((int)$songCount > -1) {

        $songCount = array(
            "songCount" => (int) $songCount
        );

        echo json_encode($songCount);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>

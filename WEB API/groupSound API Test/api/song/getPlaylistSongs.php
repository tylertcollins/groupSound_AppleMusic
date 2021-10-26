<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    include_once '../../config/Database.php';
    include_once '../../class/PlaylistSong.php';

    $database = new Database();
    $db = $database->getConnection();

    $items = new PlaylistSong($db);

    $items->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();

    $stmt = $items->getPlaylistSongs();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $songArray = array();
        $songArray["songs"] = array();
        $songArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $song = array(
                "song_id" => $song_id,
                "contributor_username" => $contributor_username,
                "song_title" => $song_title,
                "song_artist" => $song_artist,
                "song_duration" => $song_duration,
                "service_provider" => $service_provider,
                "skipped" => $skipped,
                "date_added" => $date_added
            );

            array_push($songArray["songs"], $song);
        }

        echo json_encode($songArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>
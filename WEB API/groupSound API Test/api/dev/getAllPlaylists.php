<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    include_once '../../config/Database.php';
    include_once '../../class/Playlist.php';

    $database = new Database();
    $db = $database->getConnection();

    $items = new Playlist($db);

    $stmt = $items->getAllPlaylists();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $playlistArray = array();
        $playlistArray["playlists"] = array();
        $playlistArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $playlist = array(
                "playlist_id" => $playlist_id,
                "playlist_name" => $playlist_name,
                "host_username" => $host_username,
                "skip_count" => $skip_count,
                "ruleset_id" => $ruleset_id,
                "playlist_invite_code" => $playlist_invite_code
            );

            array_push($playlistArray["playlists"], $playlist);
        }

        echo json_encode($playlistArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>
<?php

    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    require "../../vendor/autoload.php";

    use APIClass\UserPlaylist;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $items = new UserPlaylist($db);

    $items->username = isset($_GET['username']) ? $_GET['username'] : die();

    $stmt = $items->getUserPlaylists();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $songArray = array();
        $songArray["playlists"] = array();
        $songArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $playlist = array(
                "playlist_id" => (string)$playlist_id,
                "host_username" => (string)$host_username,
                "playlist_name" => (string)$playlist_name,
                "ruleset_id" => (string)$ruleset_id,
                "skip_count" => (string)$skip_count,
                "invite_code" => (string)$playlist_invite_code,
                "last_updated" => $last_updated,
                "playback_status" => $playback_status,
                "current_track" => $current_track
            );

            array_push($songArray["playlists"], $playlist);
        }

        echo json_encode($songArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }

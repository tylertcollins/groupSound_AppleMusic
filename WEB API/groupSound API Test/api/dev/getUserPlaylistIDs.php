<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    include_once '../../config/Database.php';
    include_once '../../class/Playlist.php';

    $database = new Database();
    $db = $database->getConnection();

    $items = new Playlist($db);

    $items->username = isset($_GET['username']) ? $_GET['username'] : die();

    $stmt = $items->getUserPlaylistIDs();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $playlistArray = array();
        $playlistArray["playlist_ids"] = array();
        $playlistArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $playlist = array(
                "playlist_id" => $playlist_id
            );

            array_push($playlistArray["playlist_ids"], $playlist);
        }

        echo json_encode($playlistArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>
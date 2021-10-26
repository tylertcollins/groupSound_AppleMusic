<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
require "../../vendor/autoload.php";

    use APIClass\PlaylistSong;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $playlistSong = new PlaylistSong($db);
    $data = json_decode(file_get_contents("php://input"));

    $playlistSong->playlist_id = $data->playlist_id;
    $playlistSong->song_id = $data->song_id;
    $playlistSong->contributor_username = $data->contributor_username;
    $playlistSong->date_added = $data->date_added;

    if ($playlistSong->removeSongFromPlaylist()) {
        http_response_code(202);
        echo "Track has been deleted successfully";
    } else {
        http_response_code(404);
        echo "Track could not be removed";
    }
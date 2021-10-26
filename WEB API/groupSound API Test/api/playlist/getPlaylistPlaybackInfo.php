<?php
header("Access-Control-Allow_Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/Database.php';
include_once '../../class/PlaylistSong.php';
include_once '../../class/Playlist.php';

$database = new Database();
$db = $database->getConnection();

$playlistQueue = new PlaylistSong($db);
$playlist = new Playlist($db);

$playlistQueue->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();
$playlist->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();

$queueStmt = $playlistQueue->getPlaylistSongs();
$itemCount = $queueStmt->rowCount();

$playbackStmt = $playlist->getPlaylist();

if ($itemCount > 0) {

    $songArray = array();
    $songArray["itemCount"] = $itemCount;
    $songArray["current_track"] = $playlist->current_track;

    $orderType = $playlistQueue->isOrdered();

    if ($orderType == "abc") {
        $orderedSongs = $playlistQueue->orderSongs($queueStmt);
        $songArray["songs"] = $orderedSongs;
    } else if ($orderType == "time") {
        $songArray["songs"] = array();
        while ($row = $queueStmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $song = array(
                "song_id" => $song_id,
                "contributor_username" => $contributor_username,
                "song_title" => $song_title,
                "song_artist" => $song_artist,
                "song_duration" => $song_duration,
                "service_provider" => $service_provider,
                "skipped" => $skipped,
                "has_been_played" => $has_been_played,
                "date_added" => $date_added
            );

            array_push($songArray["songs"], $song);
        }
    }

    echo json_encode($songArray);
} else {
    http_response_code(404);
    echo json_encode(
        array("message" => "No records found.")
    );
}
?>
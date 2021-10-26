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

$item = new Playlist($db);

$item->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();
$item->current_track = isset($_GET['current_track']) ? $_GET['current_track'] : die();

if ($item->updateCurrentTrack()) {
    echo json_encode("Playlist data updated.");
} else {
    echo json_encode("Data could not be updated.");
}

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

    $data = json_decode(file_get_contents("php://input"));

    $item->song_id = $data->song_id;

    if($item->deleteSong()){
        echo json_encode("Song deleted.");
    } else{
        echo json_encode("Data could not be deleted");
    }
?>

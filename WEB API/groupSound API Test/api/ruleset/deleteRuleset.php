<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

    include_once '../../config/Database.php';
    include_once '../../class/Ruleset.php';

    $database = new Database();
    $db = $database->getConnection();

    $item = new Ruleset($db);

    $data = json_decode(file_get_contents("php://input"));

    $item->ruleset_id = $data->ruleset_id;

    if($item->deleteRuleset()){
        echo json_encode("Ruleset deleted.");
    } else{
        echo json_encode("Data could not be deleted");
    }
?>

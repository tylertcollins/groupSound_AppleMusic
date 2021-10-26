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

    $items = new UserPlaylist($db);

    $items->playlist_id = isset($_GET['playlist_id']) ? $_GET['playlist_id'] : die();

    $stmt = $items->getPlaylistUsers();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $userArray = array();
        $userArray["users"] = array();
        $userArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $user = array(
                "username" => $username
            );

            array_push($userArray["users"], $user);
        }

        echo json_encode($userArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>

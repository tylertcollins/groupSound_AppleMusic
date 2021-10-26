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

    $item->skip_type = $data->skip_type;
    $item->skips_required = $data->skips_required;
    $item->order_type = $data->order_type;
    $item->allow_explicit = $data->allow_explicit;
    $item->song_min_duration = $data->song_min_duration;
    $item->song_max_duration = $data->song_max_duration;
    $item->restrict_genre = $data->restrict_genre;
    $item->max_users = $data->max_users;
    $item->max_song_count = $data->max_song_count;
    $item->max_user_song_count = $data->max_user_song_count;
    $item->allow_repeats = $data->allow_repeats;
    $item->repeat_after = $data->repeat_after;
    $item->max_songs_add = $data->max_songs_add;

    if ($item->createRuleset()) {

        $ruleset = array(
            "ruleset_id" => $item->ruleset_id
        );

        http_response_code(201);
        echo json_encode($ruleset);
    } else {
        http_response_code(400);
        echo 'Ruleset could not be created.';
    }
?>
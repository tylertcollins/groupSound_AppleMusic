<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    require "../../vendor/autoload.php";

    use APIClass\Ruleset;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $item = new Ruleset($db);

    $item->ruleset_id = isset($_GET['ruleset_id']) ? $_GET['ruleset_id'] : die();

    $item->getRuleset();

    if ($item->order_type != null) {

        $ruleset = array(
            "ruleset_id" => $item->ruleset_id,
            "skip_type" => $item->skip_type,
            "skips_required" => $item->skips_required,
            "order_type" => $item->order_type,
            "allow_explicit" => $item->allow_explicit,
            "song_min_duration" => $item->song_min_duration,
            "song_max_duration" => $item->song_max_duration,
            "restrict_genre" => $item->restrict_genre,
            "max_users" => $item->max_users,
            "max_song_count" => $item->max_song_count,
            "max_user_song_count" => $item->max_user_song_count,
            "allow_repeats" => $item->allow_repeats,
            "repeat_after" => $item->repeat_after,
            "max_songs_add" => $item->max_songs_add
        );

        http_response_code(200);
        echo json_encode($ruleset);
    } else {
        http_response_code(404);
        echo json_encode("User not found.");
    }
    ?>

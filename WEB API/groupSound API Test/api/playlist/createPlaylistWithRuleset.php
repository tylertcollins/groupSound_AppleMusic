<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    require "../../vendor/autoload.php";

    use Config\Database;
    use APIClass\Playlist;
    use APIClass\Ruleset;
    
    $database = new Database();
    $db = $database->getConnection();

    $data = json_decode(file_get_contents("php://input"));

    $ruleset = new Ruleset($db);

    $ruleset->skip_type = $data->skip_type;
    $ruleset->skips_required = $data->skips_required;
    $ruleset->order_type = $data->order_type;
    $ruleset->allow_explicit = $data->allow_explicit;
    $ruleset->song_min_duration = $data->song_min_duration;
    $ruleset->song_max_duration = $data->song_max_duration;
    $ruleset->restrict_genre = $data->restrict_genre;
    $ruleset->max_users = $data->max_users;
    $ruleset->max_song_count = $data->max_song_count;
    $ruleset->max_user_song_count = $data->max_user_song_count;
    $ruleset->allow_repeats = $data->allow_repeats;
    $ruleset->repeat_after = $data->repeat_after;
    $ruleset->max_songs_add = $data->max_songs_add;

    if (!$ruleset->createRuleset()) {
        http_response_code(400);
        echo "Error encountered while creating ruleset";
        return;
    }
    
    $playlist = new Playlist($db);
    
    $playlist->playlist_name = $data->playlist_name;
    $playlist->host_username = $data->host_username;
    $playlist->ruleset_id = $ruleset->ruleset_id;

    if ($playlist->createPlaylist()) {

        $response = array(
          "playlist_id" => $playlist->playlist_id
        );

        http_response_code(201);
        echo json_encode($response);
    } else {
        http_response_code(400);
        echo "Error encountered while creating playlist";
    }
?>
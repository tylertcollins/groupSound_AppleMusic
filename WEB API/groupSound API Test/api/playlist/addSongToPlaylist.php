<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Methods: POST");
    header("Access-Control-Max-Age: 3600");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    require "../../vendor/autoload.php";

    use APIClass\PlaylistSong;
    use APIClass\Song;
    use APIClass\Playlist;
    use APIClass\Ruleset;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $playlistSong = new PlaylistSong($db);
    $song = new Song($db);

    $data = json_decode(file_get_contents("php://input"));

    $song->song_id = $data->song->song_id;
    $song->service_provider = $data->song->service_provider;
    $song->song_title = $data->song->song_title;
    $song->song_artist = $data->song->song_artist;
    $song->song_duration = $data->song->song_duration;
    $song->is_explicit = $data->song->is_explicit;

    if ($song->createSong()) {
        echo "Song has been created successfully\n";
    } else {
        echo "Song already exists in database\n";
    }

    $playlist = new Playlist($db);
    $playlist->playlist_id = $data->playlistSong->playlist_id;
    $playlist->getPlaylist();

//    $ruleset = new Ruleset($db);
//    $ruleset->ruleset_id = $playlist->ruleset_id;
//    $ruleset->getRuleset();
//
//    if (!$song->verifySongWithPlaylistRuleset($ruleset, $playlist, $data->playlistSong->contributor_username)) {
//        http_response_code(400);
//        echo "Song not within ruleset constraints\n";
//        return;
//    }

    $playlistSong->playlist_id = $data->playlistSong->playlist_id;
    $playlistSong->song_id = $data->playlistSong->song_id;
    $playlistSong->contributor_username = $data->playlistSong->contributor_username;
    $playlistSong->has_been_played = $data->playlistSong->has_been_played;
    $playlistSong->date_added = $data->playlistSong->date_added;

    if ($playlistSong->addSongToPlaylist()) {
        http_response_code(201);
        echo "Song has been added successfully\n";
    } else {
        http_response_code(404);
        echo "Song could not be added\n";
    }



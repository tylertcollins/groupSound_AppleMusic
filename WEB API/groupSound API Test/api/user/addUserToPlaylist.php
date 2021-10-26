<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    require "../../vendor/autoload.php";

    use APIClass\UserPlaylist;
    use APIClass\Playlist;
    use Config\Database;

    $database = new Database();
    $db = $database->getConnection();

    $playlist = new Playlist($db);
    $userPlaylist = new UserPlaylist($db);

    $playlist->playlist_invite_code = isset($_GET['invite_code']) ? $_GET['invite_code'] : die();
    $userPlaylist->username = isset($_GET['username']) ? $_GET['username'] : die();

    echo $playlist->playlist_invite_code;

    $playlist->getPlaylistWithInviteCode();
    $userPlaylist->playlist_id = $playlist->playlist_id;

    echo $playlist->playlist_id;

    if ($userPlaylist->addUserToPlaylist()) {
        http_response_code(201);
    } else {
        http_response_code(404);
    }

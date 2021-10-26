<?php

//Playlist.php

class PlaylistTest
{
    private $playlist_id;
    private $playlist_name;
    private $playlist_host;
    private $current_skip_count;
    private $ruleset_id;
    private $playlist_invite_code;
    private $created_on;
    private $current_track;
    private $playback_status;
    public $connection;

    public function __construct()
    {
        require_once('config/Database.php');
        $database_object = new Database();
        $this->connection = $database_object->getConnection();
    }

    public function getPlaylistId()
    {
        return $this->playlist_id;
    }

    public function setPlaylistId($playlist_id)
    {
        $this->playlist_id = $playlist_id;
    }

    public function getPlaylistName()
    {
        return $this->playlist_name;
    }

    public function setPlaylistName($playlist_name)
    {
        $this->playlist_name = $playlist_name;
    }

    public function getPlaylistHost()
    {
        return $this->playlist_host;
    }

    public function setPlaylistHost($playlist_host)
    {
        $this->playlist_host = $playlist_host;
    }

    public function getSkipCount()
    {
        return $this->current_skip_count;
    }

    public function setSkipCount($current_skip_count)
    {
        $this->current_skip_count = $current_skip_count;
    }

    public function getRulesetId()
    {
        return $this->ruleset_id;
    }

    public function setRulesetId($ruleset_id)
    {
        $this->ruleset_id = $ruleset_id;
    }

    public function getPlaylistInviteCode()
    {
        return $this->playlist_invite_code;
    }

    public function setPlaylistInviteCode($playlist_invite_code)
    {
        $this->playlist_invite_code = $playlist_invite_code;
    }

    public function getCreatedOn()
    {
        return $this->created_on;
    }

    public function setCreatedOn($created_on)
    {
        $this->created_on = $created_on;
    }

    public function getCurrentTrack()
    {
        return $this->current_track;
    }

    public function setCurrentTrack($current_track)
    {
        $this->current_track = $current_track;
    }

    public function getPlaybackStatus()
    {
        return $this->playback_status;
    }

    public function setPlaybackStatus($playback_status)
    {
        $this->playback_status = $playback_status;
    }

    function getPlaylistById()
    {
        $query = "
        SELECT * 
        FROM playlists 
        WHERE playlist_id = :playlist_id
        ";

        $statement = $this->connection->prepare($query);

        $statement->bindParam(":playlist_id", $this->playlist_id);

        $statement->execute();

        return $statement;
    }
}
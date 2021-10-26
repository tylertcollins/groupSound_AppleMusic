<?php
    header("Access-Control-Allow_Origin: *");
    header("Content-Type: application/json; charset=UTF-8");

    include_once '../../config/Database.php';
    include_once '../../class/Ruleset.php';

    $database = new Database();
    $db = $database->getConnection();

    $items = new Ruleset($db);

    $stmt = $items->getAllRulesets();
    $itemCount = $stmt->rowCount();

    if ($itemCount > 0) {

        $rulesetArray = array();
        $rulesetArray["rulesets"] = array();
        $rulesetArray["itemCount"] = $itemCount;

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $ruleset = array(
                "ruleset_id" => $ruleset_id,
                "skip_type" => $skip_type,
                "skips_required" => $skips_required,
                "order_type" => $order_type,
                "allow_explicit" => $allow_explicit,
                "song_min_duration" => $song_min_duration,
                "song_max_duration" => $song_max_duration,
                "restrict_genre" => $restrict_genre,
                "max_users" => $max_users,
                "max_song_count" => $max_song_count,
                "max_user_song_count" => $max_user_song_count,
                "allow_repeats" => $allow_repeats,
                "repeat_after" => $repeat_after,
                "max_songs_add" => $max_songs_add
            );

            array_push($rulesetArray["rulesets"], $ruleset);
        }

        echo json_encode($rulesetArray);
    } else {
        http_response_code(404);
        echo json_encode(
            array("message" => "No records found.")
        );
    }
?>
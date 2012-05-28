-module(feedback_feedback_controller, [Req]).
-compile(export_all).


list('GET', []) ->
    Feedbacks = boss_db:find(feedback, []),
    Timestamp = boss_mq:now("new-feedback"),
    {ok, [{feedbacks, format(Feedbacks)}, {timestamp, Timestamp}]}.

update('GET', [LastTimestamp]) ->
    io:format("waiting for new feedback since ~w~n", [list_to_integer(LastTimestamp)]),
    {ok, Timestamp, Feedbacks} = boss_mq:pull("new-feedback", list_to_integer(LastTimestamp)),
    io:format("pulled new feedback~n"),
    {json, [{timestamp, Timestamp}, {feedbacks, format(Feedbacks)}]}.

format(Feedbacks) ->
    lists:map(fun (F) ->
            {{Yr, Mo, Dy}, {Hr, Mn, Sc}} = F:create_time(),
            S = io_lib:format("~2..0w/~2..0w/~4..0w ~2..0w:~2..0w:~2..0w", [Mo,Dy,Yr,Hr,Mn,Sc]),
            F:set(create_time, S)
        end, Feedbacks).


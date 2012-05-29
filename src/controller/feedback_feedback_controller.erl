-module(feedback_feedback_controller, [Req]).
-compile(export_all).

%% Show all feedback
list('GET', []) ->
    Feedbacks = boss_db:find(feedback, []),
    Timestamp = boss_mq:now("new-feedback"),
    {ok, [{feedbacks, format(Feedbacks)}, {timestamp, Timestamp}]}.

%% Long-poll for new feedback
update('GET', [LastTimestamp]) ->
    io:format("waiting for new feedback since ~w~n", [list_to_integer(LastTimestamp)]),
    {ok, Timestamp, Feedbacks} = boss_mq:pull("new-feedback", list_to_integer(LastTimestamp)),
    io:format("pulled new feedback~n"),
    {json, [{timestamp, Timestamp}, {feedbacks, format(Feedbacks)}]}.

%% Format feedback's create_time as MM/DD/YYYY HH:MM:SS string
format(Feedbacks) ->
    lists:map(fun (F) ->
            {{Yr, Mo, Dy}, {Hr, Mn, Sc}} = F:create_time(),
            S = io_lib:format("~2..0w/~2..0w/~4..0w ~2..0w:~2..0w:~2..0w", [Mo,Dy,Yr,Hr,Mn,Sc]),
            F:set(create_time, S)
        end, Feedbacks).

%% Show the feedback entry form
create('GET', []) ->
    ok;
%% Process the feedback entry form
create('POST', []) ->
    Body = Req:post_param("feedback_text"),
    CreateTime = now(),
    F = feedback:new(id, "Anonymous Web User", "", Body, CreateTime),
    case F:save() of
        {ok, Saved} -> {ok, [{thanks, 1}]};
        {error, Messages} -> {ok, [{errors, Messages}, {new_feedback, F}]}
    end.


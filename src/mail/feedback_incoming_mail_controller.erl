-module(feedback_incoming_mail_controller).
%% -compile(export_all).
-export([authorize_/3, feedback/2]).


authorize_(User, DomainName, IPAddress) ->
    true.

%% This will handle email to 
feedback(FromAddress, Message) ->
    {<<"text">>, <<"plain">>, Headers, _Metadata, Body} = Message,
    io:format("Feedback from: ~s~n", [FromAddress]),
    io:format("----~n~s~n----~n", [Body]),
    Subject = subject(Headers),
    dump_headers(Headers),
    TS = now(),
    F = feedback:new(id, FromAddress, Subject, Body, TS),
    case F:save() of
        {ok, _Saved} -> ok;
        {error, Messages} ->
            io:format("ERRORS saving new feedback: ~p~n", [Messages]),
            ok  % response is ignored
    end.

%% Pull the subject field out of a list of tuples.
subject([]) -> "";
subject([ {<<"Subject">>, Subject} | _Rest ]) -> Subject;
subject([ _First | Rest ]) -> subject(Rest).

dump_headers([]) -> ok;
dump_headers([ {Key,Value} | Rest ]) ->
    io:format("~s=~s~n", [Key, Value]),
    dump_headers(Rest).


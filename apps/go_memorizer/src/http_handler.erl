-module(http_handler).
-export([init/3, init/2, handle/2, terminate/3, doit/1]).
init(_Type, Req, _Opts) -> {ok, Req, no_state}.
init(Req0, Opts) ->
    handle(Req0, Opts).	
terminate(_Reason, _Req, _State) -> ok.
handle(Req, State) ->
    {ok, Data0, _Req2} = cowboy_req:read_body(Req),
    {IP, _} = cowboy_req:peer(Req),
    io:fwrite("http handler got message: "),
    io:fwrite(Data0),
    io:fwrite("\n"),
    %Data1 = jiffy:decode(Data0),
    %Data = packer:unpack_helper(Data1),
    D0 = doit(Data0),
    Headers = #{ <<"content-type">> => <<"application/octet-stream">>,
	       <<"Access-Control-Allow-Origin">> => <<"*">>},
    Req4 = cowboy_req:reply(200, Headers, D0, Req),
    {ok, Req4, State}.

doit(_) ->
    {ok, X} = problems:random(),
    X.

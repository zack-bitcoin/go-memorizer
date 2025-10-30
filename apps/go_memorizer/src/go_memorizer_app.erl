-module(go_memorizer_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    inets:start(),
    start_http(),
    go_memorizer_sup:start_link().

stop(_State) ->ok.

start_http() ->
    Dispatch =
        cowboy_router:compile(
          [{'_', [
		  {"/:file", file_handler, []},
		  {"/", http_handler, []}
		 ]}]),
    Port = 8070,
    IP = {0,0,0,0},
    {ok, _} = cowboy:start_clear(
                http, [{ip, IP}, {port, Port}],
                #{env => #{dispatch => Dispatch}}),
    ok.

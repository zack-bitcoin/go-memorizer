-module(problems).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
         read/1,random/0]).
-define(BACKUP, "../../../../backup.txt").
-record(db, {many, dict}).
init(ok) -> 
    process_flag(trap_exit, true),
    case file:read_file(?BACKUP) of
        {ok, Backup} -> 
            {ok, binary_to_term(Backup)};
        {error, enoent} ->
            {ok, F} = file:open("../../../../all_games.txt", [read, raw, binary]),
            {Many, DB} = scan_file(F),
            file:close(F),
            {ok, #db{dict = DB, many = Many}}
    end.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    file:write_file(?BACKUP, term_to_binary(X)),
    io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(_, X) -> {noreply, X}.
handle_call(process_id, _, S) -> {reply, self(), S};
handle_call({read, N}, _From, X) -> {reply, dict:find(N, X#db.dict), X};
handle_call(many, _From, X) -> {reply, X#db.many, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(N) ->
    gen_server:call(?MODULE, {read, N}).
random() ->
    Many = gen_server:call(?MODULE, many),
    R = 1+trunc(Many * rand:uniform()),
    read(R).
scan_file(F0) ->
    F = "../../../../all_games.txt",
    {ok, B} = file:read_file(F),
    Lines = binary:split(B, [<<"\n">>], [global]),
    scan_file2(1, Lines, dict:new()).
scan_file2(N, [], D) -> {N, D};
scan_file2(N, [Line|T], D) -> 
    D2 = dict:store(N, Line, D),
    scan_file2(N+1, T, D2).
    

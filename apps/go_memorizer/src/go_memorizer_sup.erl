-module(go_memorizer_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-define(SERVER, ?MODULE).

-define(keys, [problems]).
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
child_maker([]) -> [];
child_maker([H|T]) -> [?CHILD(H, worker)|child_maker(T)].

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 50000,
                 period => 1},
    %ChildSpecs = [],
    Workers = child_maker(?keys),
    {ok, {SupFlags, Workers}}.

%% internal functions

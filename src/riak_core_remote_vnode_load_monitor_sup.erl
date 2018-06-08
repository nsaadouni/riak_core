-module(riak_core_remote_vnode_load_monitor_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).


%%%===================================================================
%%% API functions
%%%===================================================================
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================
init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    Restart = permanent,
    Shutdown = 2000,
    Type = worker,

    Children =
        [
            {'riak_core_index_owner_watcher', {'riak_core_index_owner_watcher', start_link, []}, Restart, Shutdown, Type, ['riak_core_index_owner_watcher']},
            {'riak_core_apl_blacklist', {'riak_core_apl_blacklist', start_link, []}, Restart, Shutdown, Type, ['riak_core_apl_blacklist']},

            %% put request from a coordinating node (in preflist)
            {'put_w', {'riak_core_remote_vnode_load_monitor', start_link, [put_w]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'put_dw', {'riak_core_remote_vnode_load_monitor', start_link, [put_dw]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'put_fail', {'riak_core_remote_vnode_load_monitor', start_link, [put_fail]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'put_error', {'riak_core_remote_vnode_load_monitor', start_link, [put_error]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},

            %% normal get request to all preflist nodes
            {'get_ok', {'riak_core_remote_vnode_load_monitor', start_link, [get_ok]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'get_notfound', {'riak_core_remote_vnode_load_monitor', start_link, [get_notfound]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'get_error', {'riak_core_remote_vnode_load_monitor', start_link, [get_error]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},

            %% get read repairs
            {'get_rr_ok', {'riak_core_remote_vnode_load_monitor', start_link, [get_ok]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'get_rr_notfound', {'riak_core_remote_vnode_load_monitor', start_link, [get_notfound]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']},
            {'get_rr_error', {'riak_core_remote_vnode_load_monitor', start_link, [get_error]}, Restart, Shutdown, Type, ['riak_core_remote_vnode_load_monitor']}


        ],

    {ok, {SupFlags, Children}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

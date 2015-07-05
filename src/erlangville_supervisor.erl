%%%-------------------------------------------------------------------
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Jul 2015 00:20
%%%-------------------------------------------------------------------
-module(erlangville_supervisor).
-behaviour(supervisor).
%% API
-export([start_link/0, stop/0, init/1, start_docking_station/3, stop_docking_station/1, start_child/2]).
-define(MAX_RESTART, 3).
-define(MAX_TIME, 3600).
-define(SUPERVISOR, erlangvillesupervisor).

%% @doc start the docking station supervisor
%% starts the supervisor with name "erlangvillesupervisor"
-spec start_link() -> pid().
start_link() ->
  supervisor:start_link({local, ?SUPERVISOR}, ?MODULE, []).

%% @doc stop the docking station supervisor
stop() ->
  case whereis(?MODULE) of
    P when is_pid(P) ->
      exit(P, kill);
    _ -> ok
  end.

%% @doc init function for supervisor behaviour
init([]) ->
  {ok, {{one_for_one, ?MAX_RESTART, ?MAX_TIME}, []}}.


start_docking_station(DockRef, Total, Occupied) ->
  ChildSpec = {DockRef,
    {erlangville_gen_server, start_link, [DockRef, Total, Occupied]},
    permanent, infinity, worker, [erlangville_gen_server]},
  supervisor:start_child(?SUPERVISOR, ChildSpec).


stop_docking_station(DocRef) ->
  supervisor:terminate_child(?SUPERVISOR, DocRef),
  supervisor:delete_child(?SUPERVISOR, DocRef).


start_child(Total, Occupied) ->
  DockRef =list_to_atom(erlangville_dock_station:get_random_string(20)),
  ChildSpec = {DockRef,
    {erlangville_gen_server, start_link, [DockRef, Total, Occupied]},
    permanent, infinity, worker, [erlangville_gen_server]},
  supervisor:start_child(?SUPERVISOR, ChildSpec),
  {ok, DockRef}.

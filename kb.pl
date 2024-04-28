:- dynamic position/3.
:- dynamic has/2.
:- dynamic stepping_on/2.
:- dynamic is_closed/1.
:- dynamic is_wall/2.
:- dynamic explored/2.
:- dynamic has_entered/0.

action(open_door) :- has(agent, key),
                    position(agent, AgentR, AgentC),
                    position(door, DoorR, DoorC),
                    is_closed(door),
                    is_close(AgentR, AgentC, DoorR, DoorC).

action(pick) :- stepping_on(agent, _), is_pickable(_).

action(move_towards_goal(Direction)) :- position(agent, AgentR, AgentC),
                                        next_goal(Goal),
                                        position(Goal, GoalR, GoalC),
                                        next_direction(AgentR, AgentC, GoalR, GoalC, D),
                                        is_walkable(AgentR, AgentC, D, Direction),
                                        resulting_position(AgentR, AgentC, NewR, NewC, Direction),
                                        \+ explored(NewR, NewC).

action(move(Direction)) :- position(agent, AgentR, AgentC),
                            is_walkable(AgentR, AgentC, D, Direction),
                            resulting_position(AgentR, AgentC, NewR, NewC, Direction),
                            \+ explored(NewR, NewC).

is_close(R1, C1, R2, C2) :- R1 == R2, (C1 is C2+1; C1 is C2-1).
is_close(R1, C1, R2, C2) :- C1 == C2, (R1 is R2+1; R1 is R2-1).
is_close(R1, C1, R2, C2) :- (R1 is R2+1; R1 is R2-1), (C1 is C2+1; C1 is C2-1).

next_direction(R1, C1, R2, C2, D) :-
    ( R1 == R2 -> ( C1 > C2 -> D = west; D = east );
        ( C1 == C2 -> ( R1 > R2 -> D = north; D = south);
            ( R1 > R2 -> ( C1 > C2 -> D = northwest; D = northeast );
                ( C1 > C2 -> D = southwest; D = southeast )
    ))).

next_goal(Goal) :- is_closed(door) -> (has(agent, key) -> Goal = door; Goal = key); has_entered(agent) -> Goal = exit; Goal = door.

is_walkable(R, C, D, Direction) :- resulting_position(R, C, NewR, NewC, D),
                                    ((is_wall(NewR, NewC); (position(door, NewR, NewC), is_closed(door))) -> (close_direction(D, ND), is_walkable(R, C, ND, Direction));
                                        ((diagonal_move(D), (position(door, NewR, NewC); position(door, R, C))) -> close_direction_door(R, C, D, Direction);
                                                            Direction = D)).

diagonal_move(D) :- D == northeast; D == southeast; D == northwest; D == southwest.

close_direction_door(R, C, D, Direction) :- (D == northeast -> ((resulting_position(R, C, NewR, NewC, north), \+is_wall(NewR, NewC)) -> Direction = north; Direction = east);
                                                (D == southeast -> ((resulting_position(R, C, NewR, NewC, south), \+is_wall(NewR, NewC)) -> Direction = south; Direction = east);
                                                    (D == northwest -> ((resulting_position(R, C, NewR, NewC, north), \+is_wall(NewR, NewC)) -> Direction = north; Direction = west);
                                                        ((resulting_position(R, C, NewR, NewC, south), \+is_wall(NewR, NewC)) -> Direction = south; Direction = west)))).

%%%% known facts %%%%

resulting_position(R, C, NewR, NewC, north) :-
    NewR is R-1, NewC = C.
resulting_position(R, C, NewR, NewC, south) :-
    NewR is R+1, NewC = C.
resulting_position(R, C, NewR, NewC, west) :-
    NewR = R, NewC is C-1.
resulting_position(R, C, NewR, NewC, east) :-
    NewR = R, NewC is C+1.
resulting_position(R, C, NewR, NewC, northeast) :-
    NewR is R-1, NewC is C+1.
resulting_position(R, C, NewR, NewC, northwest) :-
    NewR is R-1, NewC is C-1.
resulting_position(R, C, NewR, NewC, southeast) :-
    NewR is R+1, NewC is C+1.
resulting_position(R, C, NewR, NewC, southwest) :-
    NewR is R+1, NewC is C-1.

close_direction(north, northeast).
close_direction(northeast, east).
close_direction(east, southeast).
close_direction(southeast, south).
close_direction(south, southwest).
close_direction(southwest, west).
close_direction(west, northwest).
close_direction(northwest, north).

has(agent, _) :- fail.

is_closed(door).

is_pickable(key).
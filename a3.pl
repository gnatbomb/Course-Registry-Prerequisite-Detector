/*
CMPUT 325 Winter 2019 Assignment 3
CCID nbombard Student name Nicholas Bombardieri

Question 1 alternate(+L1, +L2, ?L)

L1 and L2 should take turns popping their first element into a list. Once one is [], put the rest of the elements into the list and return.
*/

%Base case: A and B are [], or A is [...], and B is []. Either way, set L = A.
alternate(A, [], A).

%Base case: A is [], but B is [...]. Set L = B.
alternate([], B, B) :- B \== [].

%Main loop. Puts First two elements at start of list, then appends it with the recursive call.
alternate([First | Rest], [First2 | Rest2], L) :- 
    alternate(Rest, Rest2, L2),
    append([First, First2], L2, L).

/*
Question 2 counti(+L, ?N)
L is a possibly nested list. Find out how many ints are in the list.
*/

%Base case: L is empty list, return 0.
counti([], 0).

%Base case: L is integer, return 1.
counti(L, 1) :- integer(L).

%Base case: L is atom, return 0.
counti(L, 0) :- atom(L).

%Main loop: calls counti on first and rest. Sums their results.
counti([First|Rest], N) :- counti(First, Firstn), counti(Rest, Restn), N is Firstn + Restn.
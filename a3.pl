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


/*
Question 3 umem(-X, +L)
given an element A and the output so far (Out), add A to Out and recurse on (Out, Rest).
*/

%antimember(L, A): Returns the opposite of member(A, L).
%base case: L is empty, so A has not occurred in the list yet, and so it hasnt been seen yet. Return true.
antimember([], _).

%Main loop: check if A == First. If it does, return false, otherwise, recurse on Rest.
antimember([First|Rest], A) :- First \== A, antimember(Rest, A).

%umemhelper: Recusive caller for this function. Lets us get a list so tha we can return X as a member of that list.
%Base case: A is empty, so no more elements to check. Return the list so far.
umemhelper(Oldlist, [], Oldlist).

%Main Loop, First not in Oldlist: append First and Oldlist into Nextlist, then recurse on Nextlist and Rest.
umemhelper(Oldlist, [First|Rest], Newlist) :- 
   antimember(Oldlist, First),
   append(Oldlist, [First], Nextlist),
   umemhelper(Nextlist, Rest, Newlist).

%Main loop, First in Oldlist: recurse on Oldlist and Rest.
umemhelper(Oldlist, [First|Rest], Newlist) :- 
   member(First, Oldlist),
   umemhelper(Oldlist, Rest, Newlist).

%Original function call: calls helper function and gives appropriate return using member(X, Newx).
umem(X, L) :- umemhelper([], L, Newx), member(X, Newx).


/*
Question 4 Course Prerequisites

Question 4.1 required(+C, ?L)
Returns the prerequisites of C in L.
*/

%Base case: all prerequistes have been listed.
req([], []).

/*
Main loop: Finds the list of all prerequisites of First. Recurses on that to get Firstreqlist.
Then appends First to the end of Firstreqlist to get Newlist.
Then recurses on Rest, and appends its results to the end of Newlist, and returns the result.
*/
req([First|Rest], L) :-
    findall(Course, prerequisite(Course, First), Firstreq),
    req(Firstreq, Firstreqlist),
    append(Firstreqlist, [First], Newlist),
    req(Rest, Restlist),
    append(Newlist, Restlist, L).
    
/*
First call: gets the prerequisites of C, and then calls req on that list to get Preumeml.
Preumeml might have duplicate courses (assuming that two direct prerequisites of C have the same prerequisite),
so we call umemhelper from question 3 on Preumeml to only return the list of unique prerequisites.
*/
%First loop: calls firstreq 
required(C, L) :-
    findall(Course, prerequisite(Course, C), Maincoursereq),
    req(Maincoursereq, Preumeml),
    umemhelper([], Preumeml, L).


/*
Question 4.2 can_take(+L, ?C)
Given a list L of courses, return the list C of courses that the user can take, OR if C is given, return whether or not C can be taken.
*/

/*
Remove_a_from_b returns all B - A.
*/
%Remove_a_from_b(A, B, Inbandnotina): Returns Inbandnotina = B - A.
%Base case: no more B. Return [].
remove_a_from_b(_, [], []).

%Main loop if First is in A: Recurse on Rest.
remove_a_from_b(A, [First|Rest], Inbandnotina) :-
    member(First, A),
    remove_a_from_b(A, Rest, Inbandnotina).

%Main loop if First isnt in A: recurse on Rest, and append that result to First into Inbandnotina.
remove_a_from_b(A, [First|Rest], Inbandnotina):-
    antimember(A, First),
    remove_a_from_b(A, Rest, Restinbandnotina),
    append([First], Restinbandnotina, Inbandnotina).

/*
get_cantakes returns courses in possiblecantakes whose prerequisites are all in taken.
*/
%get_cantakes(Taken, Possiblecantakes, Cantakelist): returns all elements from Possiblecantakes whose prerequisites are met by Taken.
%Base case: no more Possiblecantakes, return [].
get_cantakes(_, [], []).

%Main loop if prereqs for first are in Taken: recurse on Rest and put this in Restcantakelist and append it to First, and return that.
get_cantakes(Taken, [First|Rest], Cantakelist) :-
    required(First, Requisites),
    remove_a_from_b(Taken, Requisites, Unmetrequisites),
    Unmetrequisites == [],
    get_cantakes(Taken, Rest, Restcantakelist),
    append([First], Restcantakelist, Cantakelist).

%Main loop if prereqs for first are not all in Taken: recurse on Rest.
get_cantakes(Taken, [First|Rest], Cantakelist) :-
    required(First, Requisites),
    remove_a_from_b(Taken, Requisites, Unmetrequisites),
    Unmetrequisites \== [],
    get_cantakes(Taken, Rest, Cantakelist).

/*
can_take gets all listed courses using findall and puts them in allcourses.
It then removes taken courses from allcourses and saves the result in possiblecantakes.
Then it calls get_cantakes to get the list of courses that haven't been taken but whose prereqs are met.
Then it returns each member of cantakelist one at a time.
*/

can_take(Taken, Cantake) :-
    findall(C, course(C), Allcourses),
    remove_a_from_b(Taken, Allcourses, Possiblecantakes),
    get_cantakes(Taken, Possiblecantakes, Cantakelist),
    member(Cantake, Cantakelist).


/*
Question 4.3 in_cycle(+C, -Cycle)
Given a course, return "C0, C1, C2, ... Cn, C0", where Ci is a prerequisited to C(i+1), and Cn is a prerequisite for C0.
If no such cycle exists, return false.
*/
%basecase:  originalcourse is a prereq to a course that is a prereq to it. Return originalcourse.
get_cycle(Originalcourse, [First|_], Cyclesofar, Returnvalue) :-
    Originalcourse == First,
    append(Cyclesofar, First, Returnvalue).

get_cycle(Originalcourse, [First], Cyclesofar, Returnvalue) :-
    antimember(Cyclesofar, First),
    findall(C, prerequisite(First, C), Isprereqforlist),
    append(Cyclesofar, First, Newcyclesofar),
    get_cycle(Originalcourse, Isprereqforlist, Newcyclesofar, Returnvalue).

get_cycle(Originalcourse, [First|Rest], Cyclesofar, Returnvalue) :-
    Originalcourse \== First,
    member(First, Cyclesofar),
    get_cycle(Originalcourse, Rest, Cyclesofar, Returnvalue).

    

%in_cycle gets all of the classes that Course is a prerequisite for and calls get_cycle on that list.
in_cycle(Course, Cycle) :- 
    findall(C, prerequisite(Course, C), Isprereqforlist),
    get_cycle(Course, Isprereqforlist, [Course], Cycle).
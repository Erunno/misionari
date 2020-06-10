%
% SOLVE
%

%hledej(+Misionari, +Lidojedi, +Reky, -NalezenaCesta)
hledej(M, L, R, Path) :-
    startStav(L, M, R, Start),
    cilStav(L, M, R, Cil),
    bfs_heur([[Start]], Cil, PathRev),
    reverse(PathRev, Path).


%
% Stavovy prostor
%

%presunLidi(+Odkud, +Kam, -NovyOdkud, -NovyKam)
presunLidi(b(L1, M1), b(L2,M2), b(L1n, M1n), b(L2n,M2n)) :-
    L1n is L1 - 2, M1n is M1, L2n is L2 + 2, M2n is M2;
    L1n is L1 - 1, M1n is M1 - 1, L2n is L2 + 1, M2n is M2 + 1;
    L1n is L1, M1n is M1 - 2, L2n is L2, M2n is M2 + 2;
    L1n is L1, M1n is M1 - 1, L2n is L2, M2n is M2 + 1;
    L1n is L1 - 1, M1n is M1, L2n is L2 + 1, M2n is M2.

%platnyBreh(+Breh)
platnyBreh(b(L, M)) :- L =< M, L >= 0, M >= 0, !.
platnyBreh(b(L, M)) :- M = 0, L >= 0.

%prohod(+Lod, -NovaPozice)
prohod(l,p).
prohod(p,l).

%upravStav(+Stav, -Stav)
upravStav([BrehLevy, Lod, BrehPravy | Zbytek], Result) :-
    (Lod == p -> presunLidi(BrehPravy, BrehLevy, NovyPravy, NovyLevy)
    ;Lod == l -> presunLidi(BrehLevy, BrehPravy, NovyLevy, NovyPravy)
    ;jinak = chyba),
    platnyBreh(NovyLevy), platnyBreh(NovyPravy),
    prohod(Lod, NovaLod),
    Result = [NovyLevy, NovaLod, NovyPravy | Zbytek].

%genStav(+PocatecniStav, -NovyStav)
genStav(Stav, Result) :-
    upravStav(Stav, Result).
genStav([BrehLevy, Lod, BrehPravy | Zbytek], [BrehLevy, Lod | Result]) :-
    genStav([BrehPravy | Zbytek], Result).

%startStav(+Lidojedi, +Misionari, +Reky, -StartStav)
startStav(L,M, 0, [b(L,M)]) :- !.
startStav(L,M,R, [b(0,0), p | StartStav]) :-
    NoveR is R - 1,
    startStav(L,M,NoveR, StartStav).

%cilStav(+Lidojedi, +Misionari, +Reky, -CilStav)
cilStav(L,M, R, CilStav) :- cilStav_(L,M,R,Tmp), reverse(Tmp, CilStav).
cilStav_(L,M, 0, [b(L,M)]) :- !.
cilStav_(L,M,R, [b(0,0), l | CilStav]) :-
    NoveR is R - 1,
    cilStav_(L,M,NoveR, CilStav).

%
% Prohledavani
%

%selectNej(+Cesty, -Vybrana, -Zbyle)
selectNej(Cesty, X, Xs) :- maxVal(Cesty, _, X, Xs).

%selectNej - trivialni - klasicka fronta, bere prvni cestu na rade
%selectNej([C|Cs],C,Cs).

%valCesta(+Cesta, +Factor, -Hodnota)
valCesta(Cesta, F, Val) :-
    [Stav|_] = Cesta,
    valStav(Stav, F, ValStav),
    length(Cesta, L),
    Val is (L*F)+ValStav.

%valStav(+Satav, +Factor, -Hodnota)
valStav([b(N,M)], F, Val) :-
    Val is (N + M) * F.
valStav([b(N,M), _ | Rest], F, Val) :-
    LocVal is (N + M) * F,
    NewF is F - 1,
    valStav(Rest, NewF, TailVal),
    Val is TailVal + LocVal.

%faktor nasobeni
f(10).

%maxVal(+Cesty, -Max, -MaxCesta, -ZbytekCest)
maxVal([Cesta], Val, Cesta, []) :- f(F), valCesta(Cesta, F, Val).
maxVal([C|Cs], Max, MaxCesta, Zbytek) :-
    f(F),
    valCesta(C, F, Val),
    maxVal(Cs, TailMax, TailMaxCesta, TailZbytek),
    (TailMax >= Val -> MaxCesta = TailMaxCesta ,Max = TailMax, Zbytek = [C | TailZbytek];
     TailMax <  Val -> MaxCesta = C,            Max = Val,     Zbytek = [TailMaxCesta | TailZbytek]).

%bfs_heur(+Fronta, +Cil, -Path)
bfs_heur(Cesty, Cil, Vys) :- najdiHotovouCestu(Cesty, Cil, Vys), !.
bfs_heur(Fronta, Cil, Path) :-
    selectNej(Fronta, TopCesta, ZbyleCesty),
    [X|Xs] = TopCesta,
    findall([Y,X|Xs],
            (genStav(X,Y), \+member(Y,TopCesta)),
            NoveCesty),
    append(ZbyleCesty, NoveCesty, NovaFronta), !,
    bfs_heur(NovaFronta, Cil, Path).

%najdiHotovouCestu(+Cesty, +Cil, -Cesta)
najdiHotovouCestu([[Cil|Cs]|_], Cil, [Cil|Cs]) :- !.
najdiHotovouCestu([_|Res], Cil, Vys) :- najdiHotovouCestu(Res, Cil, Vys).



%
% program UI
%

vypisBreh(b(N,M)) :- write('('), write(N), write(','), write(M), write(')').

vypisLod(l) :- write('v__').
vypisLod(p) :- write('__v').

vypisStav([B]) :- vypisBreh(B).
vypisStav([B,L|Rest]) :- vypisBreh(B), vypisLod(L), vypisStav(Rest).

vypisCestu([]).
vypisCestu([Stav|Rest]) :-
    vypisStav(Stav),
    nl,
    vypisCestu(Rest).

vypisTopPro(Cesta) :-
    [Stav|_] = Cesta,
    length(Stav, L),
    Brehy is (L + 1) / 2,
    vypisTop(Brehy), nl.

vypisTop(0).
vypisTop(Brehy) :-
    write(' L M    '),
    B is Brehy - 1,
    vypisTop(B).

main :-
    write('Pocet rek: '),
    read(Reky),
    write('Pocet misionaru: '),
    read(Mis),
    write('Pocet lidojedu: '),
    read(Lidoj),
    write(' ... pocitam ...'), nl,
    hledej(Mis, Lidoj, Reky, Cesta),
    vypisTopPro(Cesta),
    vypisCestu(Cesta), !.


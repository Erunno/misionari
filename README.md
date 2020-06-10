# Misionáři - řešič

## Problém

Je zadáno **n** řek (tj. **n+1** za sebou jdoucích břehů), **m** misionářů a **l** lidojedů, na každé řece je loď která uveze maximálně dva lidi. Nejprve jsou všichni cestující na nejpravějším břehu, cílem je dostat všechny na nejlevější břeh. Podmínkou je, že v žádné chvíli nesmí být na libovolném břehu více lidojedů než misionářů.

## Uživatelská příručka

Po spuštění programu vyplníte postupně počty misionářů, lidojedů a řek. Pokud existuje způsob jak všechny dostat na protější stranu, program vypíše kroky a to v následujícím formátu:

```
 L M     L M    
(0,0)__v(3,3)
(1,1)v__(2,2)
(1,0)__v(2,3)
(3,0)v__(0,3)
(2,0)__v(1,3)
(2,2)v__(1,1)
(1,1)__v(2,2)
(1,3)v__(2,0)
(0,3)__v(3,0)
(2,3)v__(1,0)
(1,3)__v(2,0)
(3,3)v__(0,0)
```

Jedná se o návod na bezpečnou dopravu. Na každém řádku je stav, který navazuje na ten předchozí. V jednom stavu každá dvojice čísel reprezentuje břeh a počty přebývajících - (lidojedi, misionáři), dále spojka mezi břehy reprezentuje řeku a pozici lodě (**v___** - loď je na levém břehu,**___v** - loď je na pravém břehu).

## Implementace

Program je realizován jako prohledávání stavového prostoru. Stav je reprezentován jako seznam břehů a pozic lodí - břeh jako **b(*počet lidojedů*,*počet misionářů*)** a loď jako **l** - loď je na levém břehu, **p** - loď je na pravém břehu.

```
%příklad - dvě řeky (tj. tři břehy) a šest cestovalů (tři lidojedi a tři misioníři)

[b(1, 0), p, b(0, 1), l, b(2,2)]
```

Tento prostor je prohledáván pomocí BFS vylepšeného o prioritní frontu, kde se v každém kroku bere cesta s největší cenou. Ohodnocující funkce je jednoduchá, čím je cesta kratší a zároveň čím má více lidí na levých březích tím je cena vyšší. I takto jednoduchá heuristika výrazně zvětšila prostor spočítatelných vstupů programu.


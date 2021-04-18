
## Optimalizace

Zásadní byl přechod z Gecode solveru na Chuffed, a následující optimalizace.

### Rotace

Řekněme, že chceme proměnnou `width[r]` nastavit na jedno z čísel `as[r]`, `bs[r]`, a `height[r]` nastavit na to druhé z nich. Naivně tuto podmínku můžeme specifikovat jako

```
(widths[r] = bs[r] /\ heights[r] = as[r])
  \/ (widths[r] = as[r] /\ heights[r] = bs[r])
```

Pokud jsme ale schopni zaručit, že `as[r] != bs[r]`, můžeme to napsat následovně

```
widths[r] in {as[r], bs[r]}
  /\ heights[r] in {as[r], bs[r]}
  /\ widths[r] != heights[r]
```

Tato druhá verze je řádově rychlejší (výpočet na 40 obdélnících se zrychlil ze 7s na 0.15s).

### Symmetry breaking u obdobných obdélníků

V případě, že je obdélník `r1` shodný (modulo rotace) s obdélníkem `r2`, můžeme provést jednoduchý symmetry breaking: je-li `r1 < r2`, poté `r1` nebude napravo od `r2`.

```
constraint forall([
  xs[r1] <= xs[r2] | r1, r2 in RECTANGLES where
    r1 < r2 /\ {as[r1], bs[r1]} = {as[r2], bs[r2]}
]);
```

U problému s 200 podobnými obdélníky (`generate(200, min=5, max=7)`) se tato podmínka zaslouží o zhruba dvojnásobné zrychlení.

### Symmetry breaking u rotace

Velkou část prohledávacího prostoru můžeme omezit tím, že u prvního obdélníku zafixujeme rotaci

```
constraint forall([
  xs[r1] <= xs[r2] | r1, r2 in RECTANGLES where
    r1 < r2 /\ {as[r1], bs[r1]} = {as[r2], bs[r2]}
]);
```

U problému s 200 podobnými obdélníky (`generate(200, min=5, max=7)`) se tato podmínka zaslouží o zhruba dvojnásobné zrychlení.
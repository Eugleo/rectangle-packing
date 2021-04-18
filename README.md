# Rectangle packing

V `data.dzn` v proměnné `rectangles` máme zadány rozměry obdélníků, které máme umístit na podkladovou obdélníkovou plochu tak, aby se nepřekrývaly, a zároveň aby ona podkladová ploha byla co nejmenší — rozměry této plochy jsou také výstupem našeho programu.

Zadání je navíc rozšířeno tak, že máme dovoleno obdélníky rotovat o 90 stupňů.

## Pár slov k první implementaci

Obecně:
- `rectangles` je dvourozměrné pole tvaru `RECTANGLES x 2`, kde `RECTANGLES` označuje celkový počet obdélníků
  - vstup jde vygenerovat skriptem v `generate_input.py`
  - finální implementace si poradí se 13 obdélníky o stranách délky 2 až 20 během 220s
- v prvním sloupci je délka strany `a` a v druhém délka strany `b`
- strana `a` (potažmo strana `b`) může označovat jak délku, tak šířku daného obdélníku — tímto je v programu ošetřena dříve zmíněná rotace o 90 stupňů


Základní, naivní implementace reprezentovala každý obdélník čtyřmi čísly:
- zadané `w` a `h` označující rozměry obdélníku
- `x`, `y` označující levý dolní roh obélníku — ty chceme během výpočtu určit

Pomocí skupiny několika nerovností jsme popsali podmínku "obdélníky se nepřekrývají", jednoduchou rovností zase šířku a výšku podkladové plochy.


## Pár slov k optimalizaci

Optimalzovaná verze je implementována v `model.mzn`.

- zásadní se ukázala myšlenka, že tento druh problému lze vyjádřit pomocí globální podmínky `cummulative`
  - resource je výška podkladové plochy, starty jednotlivých úloh jsou `x`-ové souřadnice obdélníků, doby trvání jsou jejich šířky, resource-requirements jejich výšky
- přechod z Gecode solveru na Chuffed zrychlil řešení přibližně o dva řády
- děláme symmetry breaking pro obdélníky stejných rozměrů
  - pokud mají dva obdélníky stejné rozměry, nesmí ten s nižším indexem v `rectangles` být napravo od toho druhého
  ```
  constraint forall([
    xs[r1] <= xs[r2] | r1, r2 in RECTANGLES where
      r1 < r2 /\ {as[r1], bs[r1]} = {as[r2], bs[r2]}
  ]);
  ```

- děláme symmetry breaking podél vertikální osy
  - první obdélník má origin v levé polovině podkladové plochy
  ```
  constraint xs[1] * 2 <= width;
  ```

- u rotace obdélníků pomohlo vyměnit původní implementaci

    ```
    (widths[r] = bs[r] /\ heights[r] = as[r])
      \/ (widths[r] = as[r] /\ heights[r] = bs[r])
    ```

    za implementaci následující (která počítá s `as[r] != bs[r]`)

    ```
    widths[r] in {as[r], bs[r]}
      /\ heights[r] in {as[r], bs[r]}
      /\ widths[r] != heights[r]
    ```

    která je několikrát rychlejší, nejspíše kvůli absenci disjunkcí

- solver obecně najdou řešení celkem rychle, dlouho jim však poté trvá dokázat, že je to opravdu to nejlepší
  - zpravidla to bývá tak 25% času hledání, 75% dokazování, že nic lepšího už není
  - měl jsem za to, že by v tomto mělo pomoci specifikovat solveru v jakém pořadí má u jednotlivých proměnných prohledávat hodnoty (např. `area` a `height` od nejmenší), ale nepomohlo
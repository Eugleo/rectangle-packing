include "cumulative.mzn";

list of string: labels =
  [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
    "N","O","P","Q","R","S","T","V","U","W","X","Y", "Z" ];

array [int, 1..2] of int: rectangles;
set of int: RECTANGLES = index_set_1of2(rectangles);

% widths and heights; we can't use `col` because the index sets don't match up
array [RECTANGLES] of int: as = [rectangles[r, 1] | r in RECTANGLES ];
array [RECTANGLES] of int: bs = [rectangles[r, 2] | r in RECTANGLES ];

int: max_side = max(as ++ bs);
int: min_side = min(as ++ bs);

% x is the position of the bottom-left corner block of a rectangle on the x-axis
array [RECTANGLES] of var 1..(max_side - min_side + 1): xs;
% similarly, y is the position of the bottom-left corner block of a rectangle on the y-axis
% we only use ys during pretty-printing
array [RECTANGLES] of var 1..(max_side - min_side + 1): ys;

array [RECTANGLES] of var 0..max([max(bs), max(as)]): widths;
array [RECTANGLES] of var 0..max([max(bs), max(as)]): heights;
constraint forall(r in RECTANGLES)(
  (widths[r] = bs[r] /\ heights[r] = as[r])
    \/ (widths[r] = as[r] /\ heights[r] = bs[r])
);

var int: width = max([xs[r] + widths[r] | r in RECTANGLES]) - 1;
var max_side..sum([max(as[r], bs[r]) | r in RECTANGLES]): height;
var int: area = width * height;

% this is basically the whole program
constraint cumulative(xs, widths, heights, height);

solve minimize area;

%% The rest of the file is here only to pretty-print the solution

constraint forall(i in RECTANGLES)(
  ys[i] <= (height - min(heights))
);

predicate between(var int: x, var int: beg, var int: end) =
  x in beg..(end - 1);
predicate between(par int: x, par int: beg, par int: end) =
  fix(x in beg..(end - 1));

predicate intersecting_along(var int: r1, var int: r2, list of var int: as, list of var int: mods) =
  between(as[r2], as[r1], as[r1] + mods[r1]) \/ between(as[r1], as[r2], as[r2] + mods[r2]);

constraint forall(r1, r2 in RECTANGLES where r1 < r2)(
  intersecting_along(r1, r2, xs, widths) -> not intersecting_along(r1, r2, ys, heights)
);

predicate in_rectangle(par int: r, par int: x, par int: y) =
  fix(between(x, xs[r], xs[r] + widths[r]) /\ between(y, ys[r], ys[r] + heights[r]));

% I'd love to have a function first
%   - first: return the index of the first element that matches the predicate, or a default value
%   - better than if exists(<PRED>) then find the index by sum(<PRED>) and then use it else ...
% Probably impossible due to MZ not having higher-order functions?
output [
  if exists(r in RECTANGLES)(in_rectangle(r, x, y)) then
    "(" ++ labels[sum([r | r in RECTANGLES where in_rectangle(r, x, y)])] ++ ")"
  else
    " . "
  endif ++ (if x = (fix(width)) then "\n" else "" endif)
  | y in reverse(1..(fix(height))), x in 1..(fix(width))
] ++ ["\n\nTotal area: \(area) (\(height) x \(width))"]

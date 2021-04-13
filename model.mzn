include "cumulative.mzn";

list of string: labels =
  [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
    "N","O","P","Q","R","S","T","V","U","W","X","Y", "Z" ];

array [int, 1..2] of int: rectangles;
set of int: RECTANGLES = index_set_1of2(rectangles);

array [RECTANGLES] of int: ws = [rectangles[r, 1] | r in RECTANGLES ];
array [RECTANGLES] of int: hs = [rectangles[r, 2] | r in RECTANGLES ];

array [RECTANGLES] of var 1..(sum(ws) - min(ws) + 1): xs;
array [RECTANGLES] of var 1..(sum(hs) - min(hs) + 1): ys;

var int: width = max([xs[i] + ws[i] | i in RECTANGLES]) - 1;
var max(hs)..sum(hs): height;

constraint cumulative(xs, fix(ws), fix(hs), height);

var int: area = width * height;
solve minimize area;

% output [show(area)]
% correct solution: 195

constraint forall(i in RECTANGLES)(
  ys[i] <= (height - min(hs))
);

constraint forall(r1, r2 in RECTANGLES where r1 < r2)(
  card((xs[r1]..(xs[r1] + ws[r1] - 1)) intersect (xs[r2]..(xs[r2] + ws[r2] - 1))) > 0
    -> card((ys[r1]..(ys[r1] + hs[r1] - 1)) intersect (ys[r2]..(ys[r2] + hs[r2] - 1))) = 0
);

predicate in_rectangle(var int: r, var int: x, var int: y) =
  fix(x >= xs[r] /\ x < xs[r] + ws[r] /\ y >= ys[r] /\ y < ys[r] + hs[r]);

output [
  if exists(r in RECTANGLES)(in_rectangle(r, x, y)) then
    "(" ++ labels[sum([r | r in RECTANGLES where in_rectangle(r, x, y)])] ++ ")"
  else
    " . "
  endif ++ (if x = (fix(width)) then "\n" else "" endif)
  | y in reverse(1..(fix(height))), x in 1..(fix(width))
] ++ ["\n\nTotal area: \(area), \(height), \(width)"]

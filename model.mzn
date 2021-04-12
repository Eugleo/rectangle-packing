set of int: RECTANGLES = 1..8;

array [RECTANGLES, 1..2] of int: dimensions = [|
  18, 6 | 3, 4 | 4,10 | 5, 2 | 6, 13 | 2, 2 | 7, 1 | 1, 7
|];
array [RECTANGLES] of string: labels = ["A", "B", "C", "D", "E", "F", "G", "H"];

array [RECTANGLES] of int: ws = col(dimensions, 1);
array [RECTANGLES] of int: hs = col(dimensions, 2);

array[RECTANGLES] of var min(ws)..sum(ws): top_x;
array[RECTANGLES] of var min(hs)..sum(hs): top_y;
array[RECTANGLES] of var 0..(sum(ws) - min(ws)): bottom_x;
array[RECTANGLES] of var 0..(sum(hs) - min(hs)): bottom_y;

constraint forall(r in RECTANGLES)(
  top_x[r] - bottom_x[r] = ws[r] - 1 /\ top_y[r] - bottom_y[r] = hs[r] - 1
);

constraint forall(r1, r2 in RECTANGLES where r1 < r2) (
  bottom_y[r1] > top_y[r2]
    \/ top_y[r1] < bottom_y[r2]
    \/ bottom_x[r1] > top_x[r2]
    \/ top_x[r1] < bottom_x[r2]
);

var int: width = max(top_x) - min(bottom_x);
var int: height = max(top_y) - min(bottom_y);
var int: total_area = width * height;

solve minimize total_area;

predicate in_rectangle(var int: r, var int: i, var int: j) =
  fix(i >= bottom_x[r] /\ i <= top_x[r] /\ j >= bottom_y[r] /\ j <= top_y[r]);

output [
  if exists(r in RECTANGLES)(in_rectangle(r, i, j)) then
    labels[sum([r | r in RECTANGLES where in_rectangle(r, i, j)])]
  else
    " "
  endif ++ (if j = fix(height) then "\n" else "" endif)
  | i in 0..fix(width), j in 0..fix(height)
];
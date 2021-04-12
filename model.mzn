set of int: RECTANGLES = 1..8;

array [RECTANGLES, 1..2] of int: dimensions = [|
  18, 6 | 3, 4 | 4,10 | 5, 2 | 6, 13 | 2, 2 | 7, 1 | 1, 7
|];
array [RECTANGLES] of string: labels = ["A", "B", "C", "D", "E", "F", "G", "H"];

array [RECTANGLES] of int: ws = [dimensions[r, 1] | r in RECTANGLES];
array [RECTANGLES] of int: hs = [dimensions[r, 2] | r in RECTANGLES];

% int: max_coord = max([sum(ys) - min(ys), sum(xs) - min(xs)]);
int: max_coord = max([sum(ws), sum(hs)]);

array[RECTANGLES, 1..4] of var 0..max_coord: corners;

constraint forall(r in RECTANGLES) (
  corners[r, 3] - corners[r, 1] = dimensions[r, 1] - 1
    /\ corners[r, 4] - corners[r, 2] = dimensions[r, 2] - 1
);

constraint forall(r1, r2 in RECTANGLES where r1 < r2) (
  corners[r1, 2] > corners[r2, 4]
    \/ corners[r1, 4] < corners[r2, 2]
    \/ corners[r1, 1] > corners[r2, 3]
    \/ corners[r1, 3] < corners[r2, 1]
);

var int: width = max([corners[r, 3] | r in RECTANGLES]) - min([corners[r, 1] | r in RECTANGLES]);
var int: height = max([corners[r, 4] | r in RECTANGLES]) - min([corners[r, 2] | r in RECTANGLES]);

var int: total_area = width * height;

solve minimize total_area;

predicate in_rectangle(var int: r, var int: i, var int: j) =
  fix(i >= corners[r, 1] /\ i <= corners[r, 3] /\ j >= corners[r, 2] /\ j <= corners[r, 4]);

output [
  if exists(r in RECTANGLES)(in_rectangle(r, i, j)) then
    labels[sum([r | r in RECTANGLES where in_rectangle(r, i, j)])]
  else
    " "
  endif ++ (if j = fix(height) then "\n" else "" endif)

  | i in 0..fix(width), j in 0..fix(height)
];
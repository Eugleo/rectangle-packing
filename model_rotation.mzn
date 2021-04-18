include "cumulative.mzn";

array [int, 1..2] of int: rectangles;
set of int: RECTANGLES = index_set_1of2(rectangles);

% widths and heights; we can't use `col` because the index sets don't match up
array [RECTANGLES] of int: as = [rectangles[r, 1] | r in RECTANGLES ];
array [RECTANGLES] of int: bs = [rectangles[r, 2] | r in RECTANGLES ];

list of int: stacked_up = [max(as[r], bs[r]) | r in RECTANGLES];

int: largest_rectangle = [r | r in RECTANGLES where max(as[r], bs[r]) = max(as ++ bs)][1];

% x is the position of the bottom-left corner block of a rectangle on the x-axis
array [RECTANGLES] of var 1..(sum(stacked_up) - min(stacked_up) + 1): xs;

array [RECTANGLES] of var 0..max(stacked_up): widths;
array [RECTANGLES] of var 0..max(stacked_up): heights;

% 90 degree rotation
constraint forall(r in RECTANGLES)(
  if as[r] = bs[r] then
    widths[r] = as[r] /\ heights[r] = bs[r]
  else
    widths[r] in {as[r], bs[r]} /\ heights[r] in {as[r], bs[r]} /\ widths[r] != heights[r]
  endif
);

% Symmetry breaking, based on rectangle dimensions, ignoring rotation
constraint forall([
  xs[r1] <= xs[r2] | r1, r2 in RECTANGLES where
    r1 < r2 /\ {as[r1], bs[r1]} = {as[r2], bs[r2]}
]);

% Symmetry breaking for symmetry along the vertical axis
constraint xs[1] * 2 <= width;

int: mindim = max([min(as[r], bs[r]) | r in RECTANGLES]);

var mindim..sum(stacked_up): width = max([xs[r] + widths[r] | r in RECTANGLES]) - 1;
var mindim..sum(stacked_up): height;
var int: area = width * height;

constraint cumulative(xs, widths, heights, height);

solve minimize area;

output ["\(area) (\(width) x \(height))"]
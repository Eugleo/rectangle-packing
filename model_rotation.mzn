include "cumulative.mzn";

list of string: labels =
  [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
    "N","O","P","Q","R","S","T","V","U","W","X","Y", "Z" ];

array [int, 1..2] of int: rectangles;
set of int: RECTANGLES = index_set_1of2(rectangles);

% widths and heights; we can't use `col` because the index sets don't match up
array [RECTANGLES] of int: ws = [rectangles[r, 1] | r in RECTANGLES ];
array [RECTANGLES] of int: hs = [rectangles[r, 2] | r in RECTANGLES ];

% x is the position of the bottom-left corner block of a rectangle on the x-axis
array [RECTANGLES] of var 1..(sum(ws) - min(ws) + 1): xs;
% similarly, y is the position of the bottom-left corner block of a rectangle on the y-axis
% we only use ys during pretty-printing
array [RECTANGLES] of var 1..(sum(hs) - min(hs) + 1): ys;


list of 0..max([max(hs), max(ws)]): dimensions = ws ++ hs;

array [RECTANGLES] of var 0..max([max(hs), max(ws)]): widths;
array [RECTANGLES] of var 0..max([max(hs), max(ws)]): heights;
constraint forall(r in RECTANGLES)(
  (widths[r] = hs[r] /\ heights[r] = ws[r])
    \/ (widths[r] = ws[r] /\ heights[r] = hs[r])
);

var int: width = max([xs[i] + widths[i] | i in RECTANGLES]) - 1;
var max(dimensions)..sum(dimensions): height;
var int: area = width * height;

% this is basically the whole program
constraint cumulative(xs, widths, heights, height);

solve minimize area;

%% The rest of the file is here only to pretty-print the solution

output ["If 90-degree rotation is allowed, we can achieve: \(area)"]
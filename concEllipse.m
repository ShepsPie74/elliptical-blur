function [e] = concEllipse(pos, number, per)

%   number : total number of concentric ellipses in and around a principal
%            ellipse under a ±'per'% limit.
%   pos : position array of the principal ellipse

stp = per/ceil(number/2);
for i = 1:number
    xo(i) = pos(1)-(((per-((i-1)*stp))*pos(3))/2) ; yo(i) = pos(2)-(((per-((i-1)*stp))*pos(4))/2);
    d1o(i) = ((1+per)-((i-1)*stp))*pos(3); d2o(i) = ((1+per)-((i-1)*stp))*pos(4);
    e(i) = imellipse(gca, [xo(i) yo(i) d1o(i) d2o(i)]);
    
    % [xo(i) yo(i)] specify the coordinates of the lower-left corner 
    % of the smallest rectangle that enclose the ellipse.
    % [d1o(i) d2o(i)] specify length and height of the rectangle.
end

end
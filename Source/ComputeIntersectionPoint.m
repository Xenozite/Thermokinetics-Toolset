function Point = ComputeIntersectionPoint(Coefficients1, Coefficients2)
X = (Coefficients2(2) - Coefficients1(2)) ./ (Coefficients1(1) - Coefficients2(1));
Y = Coefficients1(1) .* X + Coefficients1(2);
Point = [X Y];
end
function dYdX = ComputeDerivative(dY, dX)
dYdX(1) = (dY(2) - dY(1)) ./ (dX(2) - dX(1));
dYdX(length(dY)) = (dY(length(dY)) - dY(length(dY) - 1)) ./ (dX(length(dX)) - dX(length(dX) - 1));
for i = 2:length(dY) - 1
dYdX(i) = 0.5 .* (dY(i) - dY(i - 1)) ./ (dX(i) - dX(i - 1)) + 0.5 .* (dY(i + 1) - dY(i)) ./ (dX(i + 1) - dX(i));
end
end
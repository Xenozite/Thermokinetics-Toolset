function y = CaiLiu(x, Parameters)
y = (Parameters(1) .* x .^ Parameters(2)) .* ((1 - Parameters(3) .* x) .^ Parameters(4));
end
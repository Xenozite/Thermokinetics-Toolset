function y = SestakBerggren(x, Parameters)
y = (Parameters(1) .* x .^ Parameters(2)) .* ((1 - x) .^ Parameters(3)) .* ((-log(1 - x)) .^ Parameters(4));
end
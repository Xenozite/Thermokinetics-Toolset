function y = TruncatedSestakBerggren(x, Parameters)
y = (Parameters(1) .* x .^ Parameters(2)) .* ((1 - x) .^ Parameters(3));
end
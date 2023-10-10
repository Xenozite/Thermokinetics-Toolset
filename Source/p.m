function y = p(x)
y = (exp(-x) ./ x) .* Poly(x);
end
function y = I(T, E)
R = 8.3144598;
x = E ./ (R .* T);
y = E .* p(x) ./ R;
end
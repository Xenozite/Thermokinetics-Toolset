GlobalSettings;
EaBuffer = 100:100:200000;
[X, Y] = meshgrid(TargetConversions, EaBuffer);
for StageId = 1:StagesCount
for TargetConversionId = 1:length(TargetConversions)
MinimumEa = Inf;
MinimumFunc = Inf;
for EaId = 1:length(EaBuffer)
Sum = 0;
for i = 1:length(InitialVelocities)
for j = 1:length(InitialVelocities)
if i ~= j
Sum = Sum + InitialVelocities(j) .* I(SameConversionsTemperatures{StageId}(TargetConversionId, i), EaBuffer(EaId)) ./ (InitialVelocities(i) .* I(SameConversionsTemperatures{StageId}(TargetConversionId, j), EaBuffer(EaId)));
end
end
end
Result = Sum - length(InitialVelocities) * (length(InitialVelocities) - 1);
ZTemp(TargetConversionId, EaId) = Result;
if Result < MinimumFunc
MinimumEa = EaBuffer(EaId);
MinimumFunc = Result;
end
end
Ea{StageId}(1, TargetConversionId) = MinimumEa / 1000;
end
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 * (std(Ea{StageId}) / sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(:), Ea{StageId}(1, :), 5);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(:)));
Z = transpose(ZTemp);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
surf(X, Y, Z, 'FaceAlpha', 0.85, 'EdgeColor', 'none');
colormap turbo;
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
zlabel('$\Phi(E_{a})=\sum_{i=1}^{n}\sum_{j\neq i}^{n}\frac{I(E_{a}, T_{a,i})\beta_{j}}{I(E_{a}, T_{a,j})\beta_{i}}$', 'Interpreter', 'LaTex', 'FontSize', 18);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
plot(TargetConversions, Ea{StageId}, 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
plot(TargetConversions, TempEvaluation, 'Color', '#F94144');
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{kJ}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([min(Ea{StageId}) - 5 max(Ea{StageId}) + 5]);
TitleString = strcat([sprintf('Stage = %.d, ', StageId) '$E_{a} = ' sprintf('%.2f', MeanEa{StageId}) ' \pm ' sprintf('%.2f ', ErrorEa{StageId}) '\frac{kJ}{mol}$' sprintf(', Max-Min: %.2f', max(Ea{StageId}) - min(Ea{StageId}))]);
title(TitleString, 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
hold off;
end
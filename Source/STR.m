GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
for TargetConversionId = 1:length(TargetConversions)
STRLeftSide{StageId}(TargetConversionId, VelocityId) = log(InitialVelocities(VelocityId)) - log(TargetConversionsTemperatures{VelocityId, StageId}(TargetConversionId) .^ 1.92);
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
for TargetConversionId = 1:length(TargetConversions)
plot(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), STRLeftSide{StageId}(TargetConversionId, :));
Slope = polyfit(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), STRLeftSide{StageId}(TargetConversionId, :), 1);
Ea{StageId}(1, TargetConversionId) = Slope(1) * R  / -1.0008 / 1000;
end
hold off;
xlabel('$\frac {1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln \frac {\beta}{T^{1.92}}$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 * (std(Ea{StageId}) / sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(:), Ea{StageId}(1, :), 5);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(:)));
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
GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
for TargetConversionId = 1:length(TargetConversions)
STRLeftSide{StageId}(TargetConversionId, VelocityId) = log(InitialVelocities(VelocityId) ./ (TargetConversionsTemperatures{VelocityId, StageId}(TargetConversionId) .^ 1.92));
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
fprintf('===================================================== Stage: %d =====================================================\n', StageId);
disp(' Conversion          Ea              R2');
for TargetConversionId = 1:length(TargetConversions)
plot(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), STRLeftSide{StageId}(TargetConversionId, :));
[Slope, S] = polyfit(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), STRLeftSide{StageId}(TargetConversionId, :), 1);
SlopeData = polyval(Slope(1, :), SameConversionsReversedTemperatures{StageId}(TargetConversionId, :));
R2{StageId}(1, TargetConversionId) = 1 - (S.normr ./ norm(SlopeData - mean(SlopeData))) .^ 2;
Ea{StageId}(1, TargetConversionId) = Slope(1) .* R  ./ -1.0008;
fprintf('   %.4f        %.4f        %.4f\n', TargetConversions(TargetConversionId), Ea{StageId}(1, TargetConversionId), R2{StageId}(1, TargetConversionId));
end
hold off;
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\frac {1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln \frac {\beta}{T^{1.92}}$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 .* (std(Ea{StageId}) ./ sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(1, :), Ea{StageId}(1, :), 8);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(1, :)));
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
plot(TargetConversions, Ea{StageId}, 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
plot(TargetConversions, TempEvaluation, 'Color', '#F94144');
hold off;
Axes = gca;
Axes.YAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
TitleString = strcat([sprintf('Stage = %.d, ', StageId) '$E_{a} = ' sprintf('%.2f', MeanEa{StageId}) ' \pm ' sprintf('%.2f ', ErrorEa{StageId}) '\frac{J}{mol}$']);
title(TitleString, 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
end
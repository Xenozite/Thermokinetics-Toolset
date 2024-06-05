GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
ConversionTemperatureDerivatives{VelocityId, StageId} = ComputeDerivative(TargetConversions(1, :), TargetConversionsTemperatures{VelocityId, StageId}(1, :));
ConversionTemperatureDerivatives{VelocityId, StageId} = SGFilter(ConversionTemperatureDerivatives{VelocityId, StageId}, 8, 8, 3);
for ConversionId = 1:length(TargetConversions)
FriedmanLeftSide{StageId}(ConversionId, VelocityId) = log(InitialVelocities(VelocityId) .* ConversionTemperatureDerivatives{VelocityId, StageId}(ConversionId));
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
fprintf('===================================================== Stage: %d =====================================================\n', StageId);
disp(' Conversion          Ea              R2');
for TargetConversionId = 1:length(TargetConversions)
%plot(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), FriedmanLeftSide{StageId}(TargetConversionId, :), 'Color', '#0F00E6', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
[Slope, S] = polyfit(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), FriedmanLeftSide{StageId}(TargetConversionId, :), 1);
SlopeData = polyval(Slope(1, :), SameConversionsReversedTemperatures{StageId}(TargetConversionId, :));
plot(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), SlopeData, 'LineStyle', '-');
R2{StageId}(1, TargetConversionId) = 1 - (S.normr ./ norm(SlopeData - mean(SlopeData))) .^ 2;
Ea{StageId}(1, TargetConversionId) = Slope(1) .* R  ./ -1.0;
Error{StageId}(1, TargetConversionId) = Ea{StageId}(1, TargetConversionId) .* sqrt((1 - R2{StageId}(1, TargetConversionId)) ./ R2{StageId}(1, TargetConversionId));
fprintf('   %.4f        %.4f        %.4f\n', TargetConversions(TargetConversionId), Ea{StageId}(1, TargetConversionId), R2{StageId}(1, TargetConversionId));
end
hold off;
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\frac {1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln (\beta \frac {d \alpha}{d T})$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 .* (std(Ea{StageId}) ./ sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(1, :), Ea{StageId}(1, :), 8);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(1, :)));
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
plot(TargetConversions(:), Ea{StageId}, 'Color', '#0F00E6', 'LineStyle', '-', 'Marker', 'none', 'MarkerSize', 10);
hold on;
ConfidencePlot = fill([TargetConversions TargetConversions(end:-1:1)], [Ea{StageId} + Error{StageId} Ea{StageId}(end:-1:1) - Error{StageId}(end:-1:1)], 'b');
ConfidencePlot.FaceColor = '#0F00E6';
ConfidencePlot.EdgeColor = 'none';
ConfidencePlot.FaceAlpha = 0.125;
hold off;
Axes = gca;
Axes.YAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
TitleString = strcat([sprintf('Stage = %.d, ', StageId) 'Average ' '$E_{a} = ' sprintf('%.2f', MeanEa{StageId}) ' \pm ' sprintf('%.2f ', ErrorEa{StageId}) '\frac{J}{mol}$']);
title(TitleString, 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
end
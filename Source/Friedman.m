GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
ConversionTemperatureDerivatives{VelocityId, StageId} = [diff(TargetConversions(1, :)) ./ diff(TargetConversionsTemperatures{VelocityId, StageId}(1, :)), 0];
ConversionTemperatureDerivatives{VelocityId, StageId} = SGFilter(ConversionTemperatureDerivatives{VelocityId, StageId}, 10, 10, 3);
for ConversionId = 1:length(TargetConversions)
Temp = log(InitialVelocities(VelocityId) .* ConversionTemperatureDerivatives{VelocityId, StageId}(ConversionId));
if ~isnan(Temp) && ~isinf(Temp)
FriedmanLeftSide{StageId}(ConversionId, VelocityId) = Temp;
else
FriedmanLeftSide{StageId}(ConversionId, VelocityId) = 0;
end
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
fprintf('===================================================== Stage: %d =====================================================\n', StageId);
disp(' Conversion          Ea              R2');
for TargetConversionId = 1:length(TargetConversions) - 1
plot(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), FriedmanLeftSide{StageId}(TargetConversionId, :));
[Slope, S] = polyfit(SameConversionsReversedTemperatures{StageId}(TargetConversionId, :), FriedmanLeftSide{StageId}(TargetConversionId, :), 1);
SlopeData = polyval(Slope(1, :), SameConversionsReversedTemperatures{StageId}(TargetConversionId, :));
R2{StageId}(1, TargetConversionId) = 1 - (S.normr ./ norm(SlopeData - mean(SlopeData))) .^ 2;
Ea{StageId}(1, TargetConversionId) = Slope(1) .* R  ./ -1.0;
fprintf('   %.4f        %.4f        %.4f\n', TargetConversions(TargetConversionId), Ea{StageId}(1, TargetConversionId), R2{StageId}(1, TargetConversionId));
end
hold off;
xlabel('$\frac {1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln (\beta \frac {d \alpha}{d T})$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 .* (std(Ea{StageId}) ./ sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(1:length(TargetConversions) - 1), Ea{StageId}(1, :), 5);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(1:length(TargetConversions) - 1)));
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
plot(TargetConversions(1:length(TargetConversions) - 1), Ea{StageId}, 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
plot(TargetConversions(1:length(TargetConversions) - 1), TempEvaluation, 'Color', '#F94144');
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
TitleString = strcat([sprintf('Stage = %.d, ', StageId) 'Average ' '$E_{a} = ' sprintf('%.2f', MeanEa{StageId}) ' \pm ' sprintf('%.2f ', ErrorEa{StageId}) '\frac{J}{mol}$']);
title(TitleString, 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
hold off;
end
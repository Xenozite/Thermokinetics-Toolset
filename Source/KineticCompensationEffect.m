GlobalSettings;
for StageId = 1:StagesCount
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(1, length(InitialVelocities));
for VelocityId = 1:length(InitialVelocities)
PlotTile = nexttile;
colororder({'#0C5DA5', '#F94144'});
grid on;
hold on;
ConversionTemperatureDerivatives{VelocityId, StageId} = ComputeDerivative(TargetConversions(:), TargetConversionsTemperatures{VelocityId, StageId}(:));
for ModelId = 1:length(DifferentialModelsNames)
for ConversionId = 1:length(TargetConversions)
KCELeftSide{VelocityId, StageId}(ModelId, ConversionId) = log(InitialVelocities(VelocityId) .* ConversionTemperatureDerivatives{VelocityId, StageId}(ConversionId) ./ DifferentialModels{ModelId}(TargetConversions(ConversionId)));
end
Slope = polyfit(ReversedTargetConversionsTemperatures{VelocityId, StageId}, KCELeftSide{VelocityId, StageId}(ModelId, :), 1);
KineticPairs{VelocityId, StageId}(1, ModelId) = -Slope(1) .* R;
KineticPairs{VelocityId, StageId}(2, ModelId) = Slope(2);
end
plot(KineticPairs{VelocityId, StageId}(1, :), KineticPairs{VelocityId, StageId}(2, :), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
[KCESlope{VelocityId, StageId}, S] = polyfit(KineticPairs{VelocityId, StageId}(1, :), KineticPairs{VelocityId, StageId}(2, :), 1);
KCEData{VelocityId, StageId} = polyval(KCESlope{VelocityId, StageId}, KineticPairs{VelocityId, StageId}(1, :));
R2 = 1 - (S.normr ./ norm(KCEData{VelocityId, StageId} - mean(KCEData{VelocityId, StageId}))) .^ 2;
plot(KineticPairs{VelocityId, StageId}(1, :), KCEData{VelocityId, StageId}(1, :), 'LineStyle', ':');
Axes = gca;
Axes.XAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A, s^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
legend({'Data Points', sprintf('y = %.4f*x%.4f | R2 = %.4f', KCESlope{VelocityId, StageId}(1, 1), KCESlope{VelocityId, StageId}(1, 2), R2)}, 'Location', 'northwest');
title(PlotTile, sprintf('β = %.2f', InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
end
hold off;
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945', '#F94144'});
grid on;
hold on;
Counter = 0;
for VelocityId1 = 1:length(InitialVelocities)
plot(KineticPairs{VelocityId1, StageId}(1, :), KCEData{VelocityId1, StageId}(1, :), 'LineStyle', '-');
for VelocityId2 = 1:length(InitialVelocities)
if VelocityId1 ~= VelocityId2
Counter = Counter + 1;
Temp(Counter, :) = ComputeIntersectionPoint(KCESlope{VelocityId1, StageId}, KCESlope{VelocityId2, StageId});
end
end
end
KCEIntersectionPoints = unique(Temp, 'rows');
for VelocityId = 1:length(InitialVelocities)
plot(KCEIntersectionPoints(VelocityId, 1), KCEIntersectionPoints(VelocityId, 2), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10, 'Color', 'black');
TextString = sprintf('%.2f; %.2f', KCEIntersectionPoints(VelocityId, 1), KCEIntersectionPoints(VelocityId, 2));
text(KCEIntersectionPoints(VelocityId, 1), KCEIntersectionPoints(VelocityId, 2), TextString);
end
hold off;
Axes = gca;
Axes.XAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A, s^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
legend(string(InitialVelocities .* 60), 'Location', 'best');
title(sprintf('Kinetic Compensation Effect, Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
%==========================================================================
if UseEaMeanValue(StageId)
TargetEa{StageId} = MeanEa{StageId};
else
TargetEa{StageId} = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(:)));   
end
for EaId = 1:length(TargetEa{StageId})
lnA{StageId}(1, EaId) = KCESlope{1, StageId}(1) .* TargetEa{StageId}(1, EaId) + KCESlope{1, StageId}(2);
A{StageId}(1, EaId) = exp(lnA{StageId}(1, EaId));
end
PolyACoefficients{StageId} = polyfit(TargetEa{StageId}(:), lnA{StageId}(1, :), 1);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
plot(TargetEa{StageId}(:), lnA{StageId}(1, :), 'LineStyle', '-');
Axes = gca;
Axes.XAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A_{\alpha}, s^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
legend({sprintf('y = %.4f*x%.4f', PolyACoefficients{StageId}(1, 1), PolyACoefficients{StageId}(1, 2))}, 'Location', 'best');
title(sprintf('Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
plot(TargetConversions(1, :), lnA{StageId}(1, :), 'LineStyle', '-');
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A_{\alpha}, s^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
end
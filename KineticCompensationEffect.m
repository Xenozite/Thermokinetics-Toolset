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
xlabel('$E_{a}, \frac{kJ}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A, min^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ConversionTemperatureDerivatives{VelocityId, StageId} = [transpose(diff(TargetConversions(:)) ./ diff(TargetConversionsTemperatures{VelocityId, StageId}(:))), 0];
for ModelId = 1:length(DifferentialModelsNames) - 17
for ConversionId = 1:length(TargetConversions)
Temp = log(InitialVelocities(VelocityId) .* ConversionTemperatureDerivatives{VelocityId, StageId}(ConversionId) ./ DifferentialModels{ModelId}(TargetConversions(ConversionId)));
if ~isnan(Temp) && ~isinf(Temp)
KCELeftSide{VelocityId, StageId}(ModelId, ConversionId) = Temp;
else
KCELeftSide{VelocityId, StageId}(ModelId, ConversionId) = 0;
end
end
SHRSlope = polyfit(ReversedTargetConversionsTemperatures{VelocityId, StageId}, KCELeftSide{VelocityId, StageId}(ModelId, :), 1);
KineticPairs{VelocityId, StageId}(1, ModelId) = -SHRSlope(1) * R ./ 1000;
KineticPairs{VelocityId, StageId}(2, ModelId) = SHRSlope(2);
end
plot(KineticPairs{VelocityId, StageId}(1, :), KineticPairs{VelocityId, StageId}(2, :), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
[KCESlope{VelocityId, StageId}, S] = polyfit(KineticPairs{VelocityId, StageId}(1, :), KineticPairs{VelocityId, StageId}(2, :), 1);
KCEData{VelocityId, StageId} = polyval(KCESlope{VelocityId, StageId}, KineticPairs{VelocityId, StageId}(1, :));
R2 = 1 - (S.normr ./ norm(KCEData{VelocityId, StageId} - mean(KCEData{VelocityId, StageId}))) .^ 2;
plot(KineticPairs{VelocityId, StageId}(1, :), KCEData{VelocityId, StageId}(1, :), 'LineStyle', ':');
legend({'Data Points', sprintf('y = %.4f*x%.4f | R2 = %.4f', KCESlope{VelocityId, StageId}(1, 1), KCESlope{VelocityId, StageId}(1, 2), R2)}, 'Location', 'northwest');
title(PlotTile, sprintf('β = %.2f', InitialVelocities(VelocityId)), "FontSize", 12, "FontWeight", "normal");
end
hold off;
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945', '#F94144'});
grid on;
hold on;
for VelocityId = 1:length(InitialVelocities)
plot(KineticPairs{VelocityId, StageId}(1, :), KCEData{VelocityId, StageId}(1, :), 'LineStyle', '-');
end
hold off;
legend(string(InitialVelocities), 'Location', 'best');
xlabel('$E_{a}, \frac{kJ}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A, min^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
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
xlabel('$E_{a}, \frac{kJ}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A_{\alpha}, min^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
plot(TargetConversions(1, :), lnA{StageId}(1, :), 'LineStyle', '-');
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln A_{\alpha}, min^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
end
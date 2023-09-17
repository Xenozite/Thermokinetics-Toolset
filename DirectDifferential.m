GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
ConversionTemperatureDerivatives{VelocityId, StageId} = [transpose(diff(TargetConversions(:)) ./ diff(TargetConversionsTemperatures{VelocityId, StageId}(:))), 0];
for ModelId = 1:length(DifferentialModelsNames)
for ConversionId = 1:length(TargetConversions)
Temp = log(ConversionTemperatureDerivatives{VelocityId, StageId}(ConversionId) ./ DifferentialModels{ModelId}(TargetConversions(ConversionId)));
if ~isnan(Temp) && ~isinf(Temp)
DDLeftSide{VelocityId, StageId}(ModelId, ConversionId) = Temp;
else
DDLeftSide{VelocityId, StageId}(ModelId, ConversionId) = 0;
end
end
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(3, 3);
for VelocityId = 1:length(InitialVelocities)
for ModelId = 1:length(DifferentialModelsNames)
[P, S] = polyfit(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, 1:length(TargetConversions) - 1), DDLeftSide{VelocityId, StageId}(ModelId, 1:length(TargetConversions) - 1), 1);
PData{VelocityId, StageId}(ModelId, 1) = P(1);
PData{VelocityId, StageId}(ModelId, 2) = P(2);
ModelsData{VelocityId, StageId}(ModelId, 1) = P(1) * (-R) ./ 1000;
ModelsData{VelocityId, StageId}(ModelId, 2) = exp(P(2)) .* InitialVelocities(VelocityId);
ModelsData{VelocityId, StageId}(ModelId, 3) = 1 - (S.normr ./ norm(DDLeftSide{VelocityId, StageId}(ModelId, :) - mean(DDLeftSide{VelocityId, StageId}(ModelId, :)))) .^ 2;
end
TempBuffer = sort(ModelsData{VelocityId, StageId}(:, 3), 'descend');
for ModelDataId = 1:3
Index = find(TempBuffer(ModelDataId) == ModelsData{VelocityId, StageId}(:, 3));
EvalBuffer = polyval(PData{VelocityId, StageId}(Index, :), ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :));
PlotTile = nexttile;
plot(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), EvalBuffer, 'Color', '#FF2C00', 'LineStyle', '-');
hold on;
grid on;
plot(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), DDLeftSide{VelocityId, StageId}(Index, :), 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
hold off;
xlabel('$\frac{1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln\frac{\frac{d\alpha}{dT}}{f(\alpha)}$', 'Interpreter', 'LaTex', 'FontSize', 18);
title(PlotTile, sprintf('Model: %s, β = %.2f\nE_{α} = %.2f kJmol^{-1}, A = %.2e\nR2 = %.4f', DifferentialModelsNames(Index), InitialVelocities(VelocityId), ModelsData{VelocityId, StageId}(Index, 1), ModelsData{VelocityId, StageId}(Index, 2), ModelsData{VelocityId, StageId}(Index, 3)), "FontSize", 10, "FontWeight", "normal");
end
end
end
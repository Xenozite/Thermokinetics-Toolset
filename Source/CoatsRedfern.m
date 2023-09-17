GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
for ModelId = 1:length(DifferentialModelsNames)
for ConversionId = 1:length(TargetConversions)
CRLeftSide{VelocityId, StageId}(ModelId, ConversionId) = log(IntegralModels{ModelId}(TargetConversions(ConversionId)) ./ (TargetConversionsTemperatures{VelocityId, StageId}(ConversionId) ^ 2));
end
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(3, 3);
for VelocityId = 1:length(InitialVelocities)
for ModelId = 1:length(DifferentialModelsNames)
[P, S] = polyfit(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), CRLeftSide{VelocityId, StageId}(ModelId, :), 1);
PData{VelocityId, StageId}(ModelId, 1) = P(1);
PData{VelocityId, StageId}(ModelId, 2) = P(2);
Texp = mean(TargetConversionsTemperatures{VelocityId, StageId}(1, :));
ModelsData{VelocityId, StageId}(ModelId, 1) = P(1) * (-R) ./ 1000;
ModelsData{VelocityId, StageId}(ModelId, 2) = exp(P(2)) .* InitialVelocities(VelocityId) .* ModelsData{VelocityId, StageId}(ModelId, 1) .* 1000 / (R .* (1 - 2 .* R .* Texp ./ (1000 .* ModelsData{VelocityId, StageId}(ModelId, 1))));
ModelsData{VelocityId, StageId}(ModelId, 3) = 1 - (S.normr ./ norm(CRLeftSide{VelocityId, StageId}(ModelId, :) - mean(CRLeftSide{VelocityId, StageId}(ModelId, :)))) .^ 2;
end
TempBuffer = sort(ModelsData{VelocityId, StageId}(:, 3), 'descend');
for ModelDataId = 1:3
Index = find(TempBuffer(ModelDataId) == ModelsData{VelocityId, StageId}(:, 3));
EvalBuffer = polyval(PData{VelocityId, StageId}(Index, :), ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :));
PlotTile = nexttile;
plot(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), EvalBuffer, 'Color', '#FF2C00', 'LineStyle', '-');
hold on;
grid on;
plot(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), CRLeftSide{VelocityId, StageId}(Index, :), 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
hold off;
xlabel('$\frac{1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln\frac{g(\alpha)}{T^2}$', 'Interpreter', 'LaTex', 'FontSize', 18);
title(PlotTile, sprintf('Model: %s, β = %.2f\nE_{α} = %.2f kJmol^{-1}, A = %.2e\nR2 = %.4f', IntegralModelsNames(Index), InitialVelocities(VelocityId), ModelsData{VelocityId, StageId}(Index, 1), ModelsData{VelocityId, StageId}(Index, 2), ModelsData{VelocityId, StageId}(Index, 3)), "FontSize", 10, "FontWeight", "normal");
end
end
end
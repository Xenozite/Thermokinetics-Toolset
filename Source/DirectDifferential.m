GlobalSettings;
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
ConversionTemperatureDerivatives{VelocityId, StageId} = ComputeDerivative(TargetConversions(1, :), TargetConversionsTemperatures{VelocityId, StageId}(1, :));
for ModelId = 1:length(DifferentialModelsNames)
for ConversionId = 1:length(TargetConversions)
DDLeftSide{VelocityId, StageId}(ModelId, ConversionId) = log(ConversionTemperatureDerivatives{VelocityId, StageId}(ConversionId) ./ DifferentialModels{ModelId}(TargetConversions(ConversionId)));
end
end
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(3, length(InitialVelocities));
for VelocityId = 1:length(InitialVelocities)
for ModelId = 1:length(DifferentialModelsNames)
[P, S] = polyfit(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), DDLeftSide{VelocityId, StageId}(ModelId, :), 1);
ModelsData{VelocityId, StageId}(ModelId, 1) = DifferentialModelsNames(ModelId);
ModelsData{VelocityId, StageId}(ModelId, 2) = ModelId;                     % ModelId
ModelsData{VelocityId, StageId}(ModelId, 3) = P(1);                        % Slope
ModelsData{VelocityId, StageId}(ModelId, 4) = P(2);                        % Intercept
ModelsData{VelocityId, StageId}(ModelId, 5) = real(-R .* P(1) ./ 1000);    % Ea
ModelsData{VelocityId, StageId}(ModelId, 6) = real(exp(P(2)) .* InitialVelocities(VelocityId));
ModelsData{VelocityId, StageId}(ModelId, 7) = sprintf('%.4f', real(1 - (S.normr ./ norm(DDLeftSide{VelocityId, StageId}(ModelId, :) - mean(DDLeftSide{VelocityId, StageId}(ModelId, :)))) .^ 2));
end
SortedModelsData = sortrows(ModelsData{VelocityId, StageId}, 7, 'descend');
fprintf('===================================================== Stage: %d, Velocity: %d =====================================================\n', StageId, InitialVelocities(VelocityId) .* 60);
disp(' Model Name    Model Id       Slope          Intercept         Ea                   A                 R2');
disp(SortedModelsData);
for ModelDataId = 1:3
EvalBuffer = polyval(str2double(SortedModelsData(ModelDataId, 3:4)), ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :));
PlotTile = nexttile;
plot(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), EvalBuffer, 'Color', '#FF2C00', 'LineStyle', '-');
hold on;
grid on;
plot(ReversedTargetConversionsTemperatures{VelocityId, StageId} (1, :), DDLeftSide{VelocityId, StageId}(str2num(SortedModelsData(ModelDataId, 2)), :), 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
hold off;
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\frac{1}{T}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\ln\frac{\frac{d\alpha}{dT}}{f(\alpha)}$', 'Interpreter', 'LaTex', 'FontSize', 18);
title(PlotTile, sprintf('Model: %s, β = %.2f\nE_{α} = %.2f kJ/mol, A = %.2e\nR2 = %.4f', SortedModelsData(ModelDataId, 1), InitialVelocities(VelocityId) .* 60, SortedModelsData(ModelDataId, 5), SortedModelsData(ModelDataId, 6), SortedModelsData(ModelDataId, 7)), "FontSize", 10, "FontWeight", "normal");
end
end
end
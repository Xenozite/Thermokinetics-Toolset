GlobalSettings;
ConversionsBuffer = 0.001:0.001:0.999;
for StageId = 1:StagesCount
Z = zeros(size(ConversionsBuffer));
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
for ModelId = 1:length(DifferentialModelsNames)
for TargetConversionId = 1:length(ConversionsBuffer)
Z(TargetConversionId) = DifferentialModels{ModelId}(ConversionsBuffer(TargetConversionId)) * IntegralModels{ModelId}(ConversionsBuffer(TargetConversionId));
end
% Z(a)/Z(0.5) Scaling
HalfZIndex = find(ConversionsBuffer == median(ConversionsBuffer));
HalfZ = Z(HalfZIndex);
for TargetConversionId = 1:length(ConversionsBuffer)
Z(TargetConversionId) = Z(TargetConversionId) ./ HalfZ;
end
plot(ConversionsBuffer, Z);
end
legend(DifferentialModelsNames(1:length(DifferentialModelsNames)), 'Location', 'eastoutside', 'NumColumns', 1);
%==========================================================================
LineStyles = {'--', '-.', ':'};
Colors = {'#0C5DA5', '#00B945', '#F94144'};
for VelocityId = 1:length(InitialVelocities)
ConversionTemperatureDerivatives{VelocityId, StageId} = [diff(TargetConversions(1, :)) ./ diff(TargetConversionsTemperatures{VelocityId, StageId}(1, :)), 0];
Z = zeros(size(TargetConversions));
for TargetConversionId = 1:length(TargetConversions)
if UseEaMeanValue(StageId)
TempEa = MeanEa{StageId};
else
TempEaEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(:)));
TempEa = TempEaEvaluation(1, TargetConversionId);
end
x = TempEa ./ (R .* TargetConversionsTemperatures{1, StageId}(1, TargetConversionId));
Z(TargetConversionId) = Poly(x) .* ConversionTemperatureDerivatives{VelocityId, StageId}(1, TargetConversionId) .* TargetConversionsTemperatures{VelocityId, StageId}(1, TargetConversionId);
end
% Z(a)/Z(0.5) Scaling
HalfZIndex = find(TargetConversions == median(TargetConversions));
HalfZ = Z(HalfZIndex);
for TargetConversionId = 1:length(TargetConversions)
Z(TargetConversionId) = Z(TargetConversionId) ./ HalfZ;
end
plot(TargetConversions, Z, string(LineStyles(VelocityId)), 'Color', string(Colors(VelocityId)));
end
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\frac{Z(\alpha)}{Z(0.5)}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([0 3]);
title(sprintf('Z(α) - Master Plot, Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
hold off;
end
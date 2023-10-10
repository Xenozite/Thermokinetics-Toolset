GlobalSettings;
ConversionsBuffer = 0.001:0.001:0.999;
for StageId = 1:StagesCount
g = zeros(size(ConversionsBuffer));
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
for ModelId = 1:length(IntegralModelsNames)
for TargetConversionId = 1:length(ConversionsBuffer)
g(TargetConversionId) = IntegralModels{ModelId}(ConversionsBuffer(TargetConversionId));
end
% 0 - 1 Scaling
% MaxG = max(g);
% MinG = min(g);
% for TargetConversionId = 1:length(ConversionsBuffer)
% g(TargetConversionId) = (g(TargetConversionId) - MinG)/(MaxG - MinG);
% end
% g(a)/g(0.5) Scaling
HalfGIndex = find(ConversionsBuffer == median(ConversionsBuffer));
HalfG = g(HalfGIndex);
for TargetConversionId = 1:length(ConversionsBuffer)
g(TargetConversionId) = g(TargetConversionId) ./ HalfG;
end
plot(ConversionsBuffer, g);
end
legend(DifferentialModelsNames(1:length(DifferentialModelsNames)), 'Location', 'eastoutside', 'NumColumns', 1);
%==========================================================================
LineStyles = {'--', '-.', ':'};
Colors = {'#0C5DA5', '#00B945', '#F94144'};
for VelocityId = 1:length(InitialVelocities)
g = zeros(size(TargetConversions));
Previousg = 0;
PreviousX = 0;
PreviousT = TargetConversionsTemperatures{VelocityId, StageId}(1, 1);
for TargetConversionId = 1:length(TargetConversions)
if UseEaMeanValue(StageId)
TempEa = MeanEa{StageId};
TempA = A{StageId}(1, 1);
else
TempEaEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(:))); 
TempEa = TempEaEvaluation(1, TargetConversionId);
TempAEvaluation = exp(transpose(polyval(PolyACoefficients{StageId}, TempEaEvaluation(:))));
TempA = TempAEvaluation(1, TargetConversionId);
end
X(TargetConversionId) = exp(-TempEa ./ (R .* TargetConversionsTemperatures{VelocityId, StageId}(1, TargetConversionId)));
if TargetConversionId == 1
PreviousX = X(TargetConversionId);
end
g(TargetConversionId) = Previousg + TempA .* trapz([PreviousT TargetConversionsTemperatures{VelocityId, StageId}(1, TargetConversionId)], [PreviousX X(TargetConversionId)]) ./ InitialVelocities(VelocityId);
Previousg = g(TargetConversionId);
PreviousX = X(TargetConversionId);
PreviousT = TargetConversionsTemperatures{VelocityId, StageId}(1, TargetConversionId);
% X = TempEa ./ (R .* TargetConversionsTemperatures{VelocityId, StageId}(1, TargetConversionId));
% g(TargetConversionId) = TempA .* TempEa .* p(X) ./ (InitialVelocities(VelocityId) .* R);
end
% g(a)/g(0.5) Scaling
HalfGIndex = find(TargetConversions == median(TargetConversions));
HalfG = g(HalfGIndex);
for TargetConversionId = 1:length(TargetConversions)
g(TargetConversionId) = g(TargetConversionId) ./ HalfG;
end
plot(TargetConversions, g, string(LineStyles(VelocityId)), 'Color', string(Colors(VelocityId)));
end
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$\frac{g(\alpha)}{g(0.5)}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([0 2]);
title(sprintf('g(α) - Master Plot, Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
hold off;
end
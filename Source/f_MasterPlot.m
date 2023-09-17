GlobalSettings;
ConversionsBuffer = 0.001:0.001:0.999;
for StageId = 1:StagesCount
f = zeros(size(ConversionsBuffer));
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
for ModelId = 1:length(DifferentialModelsNames) - 12
for TargetConversionId = 1:length(ConversionsBuffer)
f(TargetConversionId) = DifferentialModels{ModelId}(ConversionsBuffer(TargetConversionId));
end
% 0 - 1 Scaling
MaxF = max(f);
MinF = min(f);
for TargetConversionId = 1:length(ConversionsBuffer)
f(TargetConversionId) = (f(TargetConversionId) - MinF) ./ (MaxF - MinF);
end
% f(a)/f(0.5) Scaling
% HalfFIndex = find(TargetConversions == 0.5);
% HalfF = f(HalfFIndex);
% for TargetConversionId = 1:length(TargetConversions)
% f(TargetConversionId) = f(TargetConversionId) ./ HalfF;
% end
plot(ConversionsBuffer, f);
end
legend(DifferentialModelsNames(1:length(DifferentialModelsNames) - 12));
%==========================================================================
LineStyles = {'--', '-.', ':'};
Colors = {'#0C5DA5', '#00B945', '#F94144'};
for VelocityId = 1:length(InitialVelocities)
ConversionTemperatureDerivatives{VelocityId, StageId} = [transpose(diff(TargetConversions(:)) ./ diff(TargetConversionsTemperatures{VelocityId, StageId}(:))), 0];
f = zeros(size(TargetConversions));
for TargetConversionId = 1:length(TargetConversions)
if UseEaMeanValue(StageId)
TempEa = MeanEa{StageId} .* 1000;
TempA = A{StageId}(1, 1);
else
TempEaEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(:)));
TempEa = TempEaEvaluation(1, TargetConversionId) .* 1000;
TempAEvaluation = exp(transpose(polyval(PolyACoefficients{StageId}, TempEaEvaluation(:))));
TempA = TempAEvaluation(1, TargetConversionId);
end
f(TargetConversionId) = InitialVelocities(VelocityId) .* ConversionTemperatureDerivatives{VelocityId, StageId}(1, TargetConversionId) ./(TempA .* exp(-TempEa ./ (R .* TargetConversionsTemperatures{VelocityId, StageId}(1, TargetConversionId))));
end
% 0 - 1 Scaling
MaxF = max(f);
MinF = min(f);
for TargetConversionId = 1:length(TargetConversions)
f(TargetConversionId) = (f(TargetConversionId) - MinF)/(MaxF - MinF);
end
% f(a)/f(0.5) Scaling
% HalfFIndex = find(TargetConversions == 0.5);
% HalfF = f(HalfFIndex);
% for TargetConversionId = 1:length(TargetConversions)
% f(TargetConversionId) = f(TargetConversionId) ./ HalfF;
% end
plot(TargetConversions, f, string(LineStyles(VelocityId)), 'Color', string(Colors(VelocityId)));
end
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$f(\alpha)$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('f(α) - Master Plot, Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
hold off;
end
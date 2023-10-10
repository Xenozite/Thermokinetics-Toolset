GlobalSettings;
EaBuffer = 1000:1000:200000;
da = 0.003125;
[X, Y] = meshgrid(TargetConversions, EaBuffer);
for StageId = 1:StagesCount
for VelocityId = 1:length(InitialVelocities)
[UniqueConversions, UniqueIndices] = unique(Conversions{VelocityId, StageId});
UniqueShiftedTemperatures = TemperatureRanges{VelocityId, StageId}(UniqueIndices);
clear UniqueIndices;
ShiftedConversionsTemperatures{VelocityId, StageId} = interp1(UniqueConversions, UniqueShiftedTemperatures, TargetConversions - da, 'makima');
clear UniqueConversions;
for TargetConversionId = 1:length(TargetConversions)
SameShiftedConversionsTemperatures{StageId}(TargetConversionId, VelocityId) = ShiftedConversionsTemperatures{VelocityId, StageId}(TargetConversionId);
end
end
for TargetConversionId = 1:length(TargetConversions)
MinimumEa = Inf;
MinimumFunc = Inf;
for EaId = 1:length(EaBuffer)
Sum = 0;
for i = 1:length(InitialVelocities)
for j = 1:length(InitialVelocities)
if i ~= j
EaConst = EaBuffer(EaId);
f = @(T) exp(-EaConst ./ (R .* T));
Sum = Sum + InitialVelocities(j) .* integral(f, SameShiftedConversionsTemperatures{StageId}(TargetConversionId, i), SameConversionsTemperatures{StageId}(TargetConversionId, i)) ./ (InitialVelocities(i) .* integral(f, SameShiftedConversionsTemperatures{StageId}(TargetConversionId, j), SameConversionsTemperatures{StageId}(TargetConversionId, j)));
end
end
end
Result = Sum - length(InitialVelocities) .* (length(InitialVelocities) - 1);
ZTemp(TargetConversionId, EaId) = Result;
if Result < MinimumFunc
MinimumEa = EaBuffer(EaId);
MinimumFunc = Result;
end
end
Ea{StageId}(1, TargetConversionId) = MinimumEa;
end
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 .* (std(Ea{StageId}) ./ sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(1, :), Ea{StageId}(1, :), 5);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(1, :)));
Z = transpose(ZTemp);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
surf(X, Y, Z, 'FaceAlpha', 0.85, 'EdgeColor', 'none');
colormap turbo;
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
zlabel('$\Phi(E_{a})=\sum_{i=1}^{n}\sum_{j\neq i}^{n}\frac{I(E_{a}, T_{a,i})\beta_{j}}{I(E_{a}, T_{a,j})\beta_{i}}$', 'Interpreter', 'LaTex', 'FontSize', 18);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
hold on;
plot(TargetConversions, Ea{StageId}, 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
plot(TargetConversions, TempEvaluation, 'Color', '#F94144');
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
TitleString = strcat([sprintf('Stage = %.d, ', StageId) 'Average ' '$E_{a} = ' sprintf('%.2f', MeanEa{StageId}) ' \pm ' sprintf('%.2f ', ErrorEa{StageId}) '\frac{J}{mol}$']);
title(TitleString, 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
hold off;
end
GlobalSettings;
FCritical = 19; % https://www.danielsoper.com/statcalc/calculator.aspx?id=4
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
MinimumFunctionValue = Inf;
S2Min = Inf;
for EaId = 1:length(EaBuffer)
Sum = 0;
S2 = 0;
for i = 1:length(InitialVelocities)
for j = 1:length(InitialVelocities)
if i ~= j
EaConst = EaBuffer(EaId);
f = @(T) exp(-EaConst ./ (R .* T));
Sum = Sum + InitialVelocities(j) .* integral(f, SameShiftedConversionsTemperatures{StageId}(TargetConversionId, i), SameConversionsTemperatures{StageId}(TargetConversionId, i)) ./ (InitialVelocities(i) .* integral(f, SameShiftedConversionsTemperatures{StageId}(TargetConversionId, j), SameConversionsTemperatures{StageId}(TargetConversionId, j)));
S2 = S2 + (InitialVelocities(j) .* integral(f, SameShiftedConversionsTemperatures{StageId}(TargetConversionId, i), SameConversionsTemperatures{StageId}(TargetConversionId, i)) ./ (InitialVelocities(i) .* integral(f, SameShiftedConversionsTemperatures{StageId}(TargetConversionId, j), SameConversionsTemperatures{StageId}(TargetConversionId, j))) - 1) .^ 2;
end
end
end
SurfaceTemp(TargetConversionId, EaId) = Sum - length(InitialVelocities) .* (length(InitialVelocities) - 1);
S2Temp(TargetConversionId, EaId) = S2;
if SurfaceTemp(TargetConversionId, EaId) < MinimumFunctionValue
MinimumEa = EaBuffer(EaId);
MinimumFunctionValue = SurfaceTemp(TargetConversionId, EaId);
S2Min = S2Temp(TargetConversionId, EaId);
end
end
S2Lim = S2Min .* FCritical;
F1 = polyfit(EaBuffer, S2Temp(TargetConversionId, :), 6);
F2 = polyfit([EaBuffer(1) EaBuffer(end)], [S2Lim S2Lim], 1);
% N1 = polyval(F1, EaBuffer);
% N2 = polyval(F2, EaBuffer);
% plot(EaBuffer, S2Temp(TargetConversionId, :));
% hold on;
% plot([EaBuffer(1) EaBuffer(end)], [S2Lim S2Lim]);
% plot(EaBuffer, N1);
% plot(EaBuffer, N2);
% hold off;
IntersectionPoints = roots(F1 - [0 0 0 0 0 F2]);
IntersectionPoints = IntersectionPoints(imag(IntersectionPoints) == 0);
if length(IntersectionPoints) == 0
    DeltaEa{StageId}(1, TargetConversionId) = 0;
else
if length(IntersectionPoints) == 1
    DeltaEa{StageId}(1, TargetConversionId) = IntersectionPoints(1) ./ 2;
else
    DeltaEa{StageId}(1, TargetConversionId) = (max(IntersectionPoints) - min(IntersectionPoints)) ./ 2;
end
end
Ea{StageId}(1, TargetConversionId) = MinimumEa;
end
MeanEa{StageId} = mean(Ea{StageId});
ErrorEa{StageId} = 1.96 .* (std(Ea{StageId}) ./ sqrt(length(Ea{StageId})));
PolyEaCoefficients{StageId} = polyfit(TargetConversions(1, :), Ea{StageId}(1, :), 8);
TempEvaluation = transpose(polyval(PolyEaCoefficients{StageId}, TargetConversions(1, :)));
VyazovkinSurface = transpose(SurfaceTemp);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
surf(X, Y, VyazovkinSurface, 'FaceAlpha', 0.85, 'EdgeColor', 'none');
colormap turbo;
Axes = gca;
Axes.YAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.ZMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
Axes.ZMinorTick = 'on';
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
zlabel('$\Phi(E_{a})=\sum_{i=1}^{n}\sum_{j\neq i}^{n}\frac{I(E_{a}, T_{a,i})\beta_{j}}{I(E_{a}, T_{a,j})\beta_{i}}$', 'Interpreter', 'LaTex', 'FontSize', 18);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
plot(TargetConversions, Ea{StageId}, 'Color', '#0C5DA5', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
hold on;
ConfidencePlot = fill([TargetConversions TargetConversions(end:-1:1)], [Ea{StageId} + DeltaEa{StageId} Ea{StageId}(end:-1:1) - DeltaEa{StageId}(end:-1:1)], 'b');
ConfidencePlot.FaceColor = '#0C5DA5';
ConfidencePlot.EdgeColor = 'none';
ConfidencePlot.FaceAlpha = 0.125;
plot(TargetConversions, TempEvaluation, 'Color', '#F94144');
hold off;
Axes = gca;
Axes.YAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
TitleString = strcat([sprintf('Stage = %.d, ', StageId) 'Average ' '$E_{a} = ' sprintf('%.2f', MeanEa{StageId}) ' \pm ' sprintf('%.2f ', ErrorEa{StageId}) '\frac{J}{mol}$']);
title(TitleString, 'Interpreter', 'LaTex', "FontSize", 12, "FontWeight", "normal");
end
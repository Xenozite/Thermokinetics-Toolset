GlobalSettings;
% Yellow = #FF9500
% Red = #F94144
% Green = #00B945
% Blue = #0C5DA5
% Purple = #B83DBA

% Red = #E60051
% Green = #00C21D
% Blue = #0F00E6
% Orange = #E86800
% Purple = #BE00D4
% Mint = #00C480
%================================ TGA+DSC =================================
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(1, length(InitialVelocities));
for VelocityId = 1:length(InitialVelocities)
PlotTile = nexttile;
colororder({'#0F00E6', '#E60051'});
grid on;
yyaxis left;
plot(TemperatureCelsius, TG(VelocityId, :), 'Color', '#0F00E6', 'LineStyle', '-');
Axes = gca;
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
ylabel('Mass change $\frac{\Delta m}{m_{0}}, \%$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([-1 101]);
yyaxis right;
plot(TemperatureCelsius, DSC(VelocityId, :), 'Color', '#E60051', 'LineStyle', '-');
Axes = gca;
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
ylabel('Heat flow, $\frac{mW}{mg}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([min(DSC(VelocityId, :)) - 0.5 0.5]);
xlabel('T, °C', 'FontSize', 14);
title(PlotTile, sprintf('TG+DSC, β = %.2f', InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
end
%================================== DTG ===================================
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(1, length(InitialVelocities));
for VelocityId = 1:length(InitialVelocities)
PlotTile = nexttile;
grid on;
plot(TemperatureCelsius, DTGPercent(VelocityId, :), 'Color', '#00C21D', 'LineStyle', '-');
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
ylabel('$\frac{dm}{dT}, \frac{\%}{K}$', 'Interpreter', 'LaTex', 'FontSize', 14);
xlabel('T, °C', 'FontSize', 14);
title(PlotTile, sprintf('DTG, β = %.2f', InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
end
%============================= Deconvolution ==============================
if PeaksCount > 0
for VelocityId = 1:length(InitialVelocities)
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
for PointId = 1:length(DTGPercent(VelocityId, :))
DTGCumulative(PointId) = 0;
for PeakId = 1:PeaksCount
DTGCumulative(PointId) = DTGCumulative(PointId) + Peaks{VelocityId}(PeakId, PointId);
end
end
grid on;
hold on;
plot(TemperatureCelsius, -SGFilter(DTGPercent(VelocityId, :), 6, 6, 3), 'Color', '#00B945', 'LineStyle', '-');
plot(TemperatureCelsius, DTGCumulative, 'Color', '#F94144', 'LineStyle', '--');
for PeakId = 1:PeaksCount
area(TemperatureCelsius, Peaks{VelocityId}(PeakId, :));
end
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
ylabel('$\frac{dm}{dT}, \frac{\%}{K}$', 'Interpreter', 'LaTex', 'FontSize', 14);
xlabel('T, °C', 'FontSize', 14);
title(PlotTile, sprintf('DTG, β = %.2f', InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
end
end
%============================== Convertions ===============================
for StageId = 1:StagesCount
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945', '#F94144'});
grid on;
hold on;
for VelocityId = 1:length(InitialVelocities)
plot(TemperatureRanges{VelocityId, StageId} - 273.15, Conversions{VelocityId, StageId});
end
hold off;
Axes = gca;
Axes.YAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
xlabel('T, °C', 'FontSize', 14);
ylabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Conversion, Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
end
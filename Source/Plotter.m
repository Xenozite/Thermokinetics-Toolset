GlobalSettings;
% Yellow = #FF9500
% Red = #F94144
% Green = #00B945
% Blue = #0C5DA5
% Purple = #B83DBA
%================================ TGA+DSC =================================
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(1, length(InitialVelocities));
for VelocityId = 1:length(InitialVelocities)
PlotTile = nexttile;
colororder({'#0C5DA5', '#B83DBA'});
grid on;
yyaxis left;
plot(TemperatureCelsius, TG(VelocityId, :), 'Color', '#0C5DA5', 'LineStyle', '-');
ylabel('Mass change $\frac{\Delta m}{m_{0}}, \%$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([-1 101]);
yyaxis right;
plot(TemperatureCelsius, DSC(VelocityId, :), 'Color', '#B83DBA', 'LineStyle', '-');
ylabel('Heat flow, $\frac{mW}{mg}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([min(DSC(VelocityId, :)) - 0.5 0.5]);
xlabel('T, °C', 'FontSize', 14);
xlim([30 500]);
title(PlotTile, sprintf('TG+DSC, β = %.2f', InitialVelocities(VelocityId)), "FontSize", 12, "FontWeight", "normal");
end
%================================== DTG ===================================
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
tiledlayout(1, length(InitialVelocities));
for VelocityId = 1:length(InitialVelocities)
PlotTile = nexttile;
grid on;
plot(TemperatureCelsius, DTGPercent(VelocityId, :), 'Color', '#00B945', 'LineStyle', 'none', 'Marker', '.');
ylabel('$\frac{dm}{dT}, \frac{mg}{K}$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([-0.45 0.05]);
xlabel('T, °C', 'FontSize', 14);
xlim([30 500]);
title(PlotTile, sprintf('DTG, β = %.2f', InitialVelocities(VelocityId)), "FontSize", 12, "FontWeight", "normal");
end
%============================== Convertions ===============================
for StageId = 1:StagesCount
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945', '#F94144'});
grid on;
hold on;
for VelocityId = 1:length(InitialVelocities)
plot(TemperatureRanges{VelocityId, StageId}, Conversions{VelocityId, StageId});
xlabel('T, K', 'FontSize', 14);
ylabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Conversion, Stage = %.d', StageId), "FontSize", 12, "FontWeight", "normal");
end
hold off;
end
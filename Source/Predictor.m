StageId = 1;
for VelocityId = 1:length(InitialVelocities)
InitialVelocity = InitialVelocities(VelocityId);
T0 = 303.15;
ConversionsBuffer = 0.00001:0.00001:0.99999;
[Alpha, T] = ode45(@(Alpha, T)EvaluateTemperatureFromConversion(Alpha, T, InitialVelocity, PolyEaCoefficients{StageId}, PolyACoefficients{StageId}, SBAverageParameters(StageId, :)), [ConversionsBuffer(1) ConversionsBuffer(end)], T0);
Alpha = transpose(Alpha);
T = transpose(T);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945'});
grid on;
hold on;
plot(Alpha, T, 'LineStyle', '-');
plot(TargetConversions, TargetConversionsTemperatures{VelocityId, StageId}, 'LineStyle', '--');
hold off;
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
legend({'Prediction', 'Experimental'}, 'Location', 'best', 'NumColumns', 1);
ylabel('T, K', 'FontSize', 14);
xlim([-0.05 1.05]);
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
title(sprintf('Temperature prediction, Stage = %.d, Velocity = %.d', StageId, InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
%==========================================================================
TempEaEvaluation = polyval(PolyEaCoefficients{StageId}, Alpha);
TempAEvaluation = exp(polyval(PolyACoefficients{StageId}, TempEaEvaluation));
TempfEvaluation = SestakBerggren(Alpha, SBAverageParameters(StageId, :));
for TargetConversionId = 1:length(Alpha)
dadT(TargetConversionId) = TempAEvaluation(TargetConversionId) .* TempfEvaluation(TargetConversionId) .* exp(-TempEaEvaluation(TargetConversionId) ./ (R .* T(TargetConversionId))) ./ InitialVelocities(VelocityId);
end
[dadTMax, TisoIndex] = max(dadT);
Tiso = T(TisoIndex);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945', '#F94144', '#B83DBA'});
plot(T, dadT, 'LineStyle', '-');
grid on;
hold on;
plot(TargetConversionsTemperatures{VelocityId, StageId}, ConversionTemperatureDerivatives{VelocityId, StageId}, 'LineStyle', '--');
plot(Tiso, dadTMax, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 14, 'Color', 'red');
TextString = sprintf('%.2f; %.4f', Tiso, dadTMax);
text(Tiso, dadTMax, TextString);
hold off;
Axes = gca;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
legend({'Prediction', 'Experimental'}, 'Location', 'best', 'NumColumns', 1);
ylabel('$\frac{d \alpha}{dT}, K^{-1}$', 'Interpreter', 'LaTex', 'FontSize', 14);
xlabel('T, K', 'FontSize', 14);
title(sprintf('Tiso prediction, Stage = %.d, Velocity = %.d', StageId, InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
%==========================================================================
Deltat = 15;
Time = 0:Deltat:18000;
HeatingLineCoefficients = polyfit([0, (Tiso - T0) ./ InitialVelocities(VelocityId)], [T0, Tiso], 1);
for i = 1:1201
TemperatureProgram(i) = polyval(HeatingLineCoefficients, (i - 1) .* Deltat);
if (TemperatureProgram(i)) > Tiso
TemperatureProgram(i) = Tiso;
end
end
PredictedAlpha(1) = 0.00001;
for i = 2:1201
TempEaEvaluation = polyval(PolyEaCoefficients{StageId}, PredictedAlpha(i - 1));
TempAEvaluation = exp(polyval(PolyACoefficients{StageId}, TempEaEvaluation));
TempfEvaluation = SestakBerggren(PredictedAlpha(i - 1), SBAverageParameters(StageId, :));
PredictedAlpha(i) = PredictedAlpha(i - 1) + Deltat .* TempAEvaluation .* TempfEvaluation .* exp(-TempEaEvaluation ./ (R .* TemperatureProgram(i)));
end
ExperimentalTime(1) = 0;
for i = 2:length(TemperatureRanges{StageId, VelocityId})
ExperimentalTime(i) = ExperimentalTime(i - 1) + (TemperatureRanges{StageId, VelocityId}(1, i) - TemperatureRanges{StageId, VelocityId}(1, i - 1)) ./ InitialVelocities(VelocityId);
end
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
colororder({'#0C5DA5', '#00B945', '#F94144', '#B83DBA'});
grid on;
yyaxis left;
plot(Time, PredictedAlpha, 'LineStyle', '-');
hold on;
plot(ExperimentalTime, Conversions{StageId, VelocityId}, 'LineStyle', '--');
hold off;
Axes = gca;
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
ylabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
ylim([0 1]);
yyaxis right;
plot(Time, TemperatureProgram, 'LineStyle', '--');
hold on;
plot(ExperimentalTime, TemperatureRanges{StageId, VelocityId}, 'LineStyle', '-.');
hold off;
Axes = gca;
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
ylabel('T, K', 'FontSize', 14);
ylim([T0 Tiso + 10]);
xlabel('t, s', 'FontSize', 14);
title(sprintf('Conversion prediction, β = %.2f', InitialVelocities(VelocityId) * 60), "FontSize", 12, "FontWeight", "normal");
end
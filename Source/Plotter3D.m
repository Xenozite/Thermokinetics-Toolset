GlobalSettings;
for StageId = 1:StagesCount
MinTemerature = TargetConversionsTemperatures{1, StageId};
MaxTemperature = TargetConversionsTemperatures{length(InitialVelocities), StageId};
MinTemerature = min(MinTemerature);
MaxTemperature = max(MaxTemperature);
FigureNumber = FigureNumber + 1;
figure(FigureNumber);
grid on;
for VelocityId = 1:length(InitialVelocities)
plot3(TargetConversions, TargetConversionsTemperatures{VelocityId, StageId}, Ea{StageId});
hold on;
end
for VelocityId = 1:length(InitialVelocities)
plot3(max(TargetConversions) .* ones(size(TargetConversions)), TargetConversionsTemperatures{VelocityId, StageId}, Ea{StageId}, 'LineStyle', '--');
plot3(TargetConversions, TargetConversionsTemperatures{VelocityId, StageId}, max(Ea{StageId}) .* ones(size(Ea{StageId})), 'LineStyle', '-.');
end
plot3(TargetConversions, MaxTemperature .* ones(size(TargetConversionsTemperatures{length(InitialVelocities), StageId})), Ea{StageId}, 'LineStyle', ':');
hold off;
Axes = gca;
Axes.ZAxis.Exponent = 0;
Axes.XMinorGrid = 'on';
Axes.YMinorGrid = 'on';
Axes.ZMinorGrid = 'on';
Axes.XMinorTick = 'on';
Axes.YMinorTick = 'on';
Axes.ZMinorTick = 'on';
legend(string(InitialVelocities .* 60), 'Location', 'best');
xlabel('$\alpha$', 'Interpreter', 'LaTex', 'FontSize', 14);
xlim([0 1]);
ylabel('T, K', 'FontSize', 14);
ylim([MinTemerature MaxTemperature]);
zlabel('$E_{a}, \frac{J}{mol}$', 'Interpreter', 'LaTex', 'FontSize', 14);
end
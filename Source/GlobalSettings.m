DifferentialModelsList;
IntegralModelsList;
InitialMass = [...];
InitialVelocities = [...];
StepsCount = 0;
Steps = [
    ...;
    ...;
    ...];
PeaksCount = 0;
StagesCount = StepsCount + PeaksCount;
FigureNumber = 0;
R = 8.3144598;
FileName = 'Data.csv';
Delimiter = ';';
HeaderLines = 0;
UseEaMeanValue = [...];
TargetConversions = 0.1:0.01:0.9;
%                    -=< Optimal Target Conversions >=-
%==========================================================================
% Vyazovkin:                    0.1:0.01:0.9
% AdvancedVyazovkin:            0.1:0.00625:0.9
% AverageLinearIntegralMethod:  0.1:0.00625:0.9
% OFW, KAS, STR:                0.1:0.01:0.9
% Friedman:                     0.1:0.01:0.9
% CoatsRedfern:                 0.01:0.01:0.99
% DirectDifferential:           0.01:0.01:0.99
% KineticCompensationEffect:    0.01:0.005:0.99
% f-MasterPlot:                 0:0.025:1
% g-MasterPlot:                 0.005:0.001:0.995
% Z-MasterPlot:                 0:0.025:1
%==========================================================================
File = importdata(FileName, Delimiter, HeaderLines);
TemperatureCelsius = transpose(File(:, 1));
TemperatureKelvins = TemperatureCelsius + 273.15;
for VelocityId = 1:length(InitialVelocities)
TG(VelocityId, :) = transpose(File(:, VelocityId + 1));
DSC(VelocityId, :) = transpose(File(:, length(InitialVelocities) + VelocityId + 1));
for PeakId = 1:PeaksCount
Peaks{VelocityId}(PeakId, :) = transpose(File(:, 2 .* length(InitialVelocities) + 1 + (VelocityId - 1) .* PeaksCount + PeakId));
end
end
%==========================================================================
for MassIndex = 1:length(InitialMass)
Mass(MassIndex, :) = InitialMass(MassIndex) .* TG(MassIndex, :) ./ 100;
DTGMass(MassIndex, :) = ComputeDerivative(Mass(MassIndex, :), TemperatureKelvins(:));
DTGPercent(MassIndex, :) = ComputeDerivative(TG(MassIndex, :), TemperatureKelvins(:));
end
%==========================================================================
for VelocityId = 1:length(InitialVelocities)
for StepId = 1:StepsCount
StartId = find(TemperatureCelsius == Steps(VelocityId, StepId));
StopId = find(TemperatureCelsius == Steps(VelocityId, StepId + 1));
StartMass = Mass(VelocityId, StartId);
StopMass = Mass(VelocityId, StopId);
for Id = 0:StopId-StartId
Conversions{VelocityId, StepId}(Id + 1) = (StartMass - Mass(VelocityId, StartId + Id)) / (StartMass - StopMass);
end
TemperatureRanges{VelocityId, StepId} = linspace(TemperatureKelvins(StartId), TemperatureKelvins(StopId), length(Conversions{VelocityId, StepId}));
[UniqueConversions, UniqueIndices] = unique(Conversions{VelocityId, StepId});
UniqueTemperatures = TemperatureRanges{VelocityId, StepId}(UniqueIndices);
clear UniqueIndices;
TargetConversionsTemperatures{VelocityId, StepId} = interp1(UniqueConversions, UniqueTemperatures, TargetConversions, 'makima');
ReversedTargetConversionsTemperatures{VelocityId, StepId} = 1 ./ TargetConversionsTemperatures{VelocityId, StepId};
clear UniqueConversions;
clear UniqueTemperatures;
for TargetConversionId = 1:length(TargetConversions)
SameConversionsTemperatures{StepId}(TargetConversionId, VelocityId) = TargetConversionsTemperatures{VelocityId, StepId}(TargetConversionId);
SameConversionsReversedTemperatures{StepId}(TargetConversionId, VelocityId) = ReversedTargetConversionsTemperatures{VelocityId, StepId}(TargetConversionId);
end
end
%==========================================================================
for PeakId = 1:PeaksCount
PeakAreas{VelocityId}(PeakId, 1) = trapz(TemperatureKelvins, Peaks{VelocityId}(PeakId, :));
PeakAreas{VelocityId}(PeakId, 1) = PeakAreas{VelocityId}(PeakId, 1) .* InitialMass(VelocityId) ./ 100;
PeakAreasPoints{VelocityId}(PeakId, :) = cumtrapz(TemperatureKelvins, Peaks{VelocityId}(PeakId, :));
PeakAreasPoints{VelocityId}(PeakId, :) = PeakAreasPoints{VelocityId}(PeakId, :) .* InitialMass(VelocityId) ./ 100;
for Index=1:length(PeakAreasPoints{VelocityId}(PeakId, :))
if PeakAreasPoints{VelocityId}(PeakId, Index) < 0.001
PeakAreasPoints{VelocityId}(PeakId, Index) = 0;
else
PeakAreasPoints{VelocityId}(PeakAreasPoints{VelocityId} == 0) = PeakAreasPoints{VelocityId}(PeakId, Index);
break;
end
end
Conversions{VelocityId, PeakId + StepsCount}(1, :) = PeakAreasPoints{VelocityId}(PeakId, :) ./ PeakAreas{VelocityId}(PeakId, 1);
TemperatureRanges{VelocityId, PeakId + StepsCount} = TemperatureKelvins;
[UniqueConversions, UniqueIndices] = unique(Conversions{VelocityId, PeakId + StepsCount});
UniqueTemperatures = TemperatureRanges{VelocityId, PeakId + StepsCount}(UniqueIndices);
clear UniqueIndices;
TargetConversionsTemperatures{VelocityId, PeakId + StepsCount} = interp1(UniqueConversions, UniqueTemperatures, TargetConversions, 'makima');
ReversedTargetConversionsTemperatures{VelocityId, PeakId + StepsCount} = 1 ./ TargetConversionsTemperatures{VelocityId, PeakId + StepsCount};
clear UniqueConversions;
clear UniqueTemperatures;
for TargetConversionId = 1:length(TargetConversions)
SameConversionsTemperatures{PeakId + StepsCount}(TargetConversionId, VelocityId) = TargetConversionsTemperatures{VelocityId, PeakId + StepsCount}(TargetConversionId);
SameConversionsReversedTemperatures{PeakId + StepsCount}(TargetConversionId, VelocityId) = ReversedTargetConversionsTemperatures{VelocityId, PeakId + StepsCount}(TargetConversionId);
end
end
end
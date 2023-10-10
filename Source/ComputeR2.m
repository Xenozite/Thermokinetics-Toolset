function R2 = ComputeR2(ExperimentalData, ModelData)
Residual = ExperimentalData - ModelData;
ResidualNorm = norm(Residual);
SSE = ResidualNorm .^ 2;
SST = norm(ExperimentalData - mean(ExperimentalData)) .^ 2;
R2 = 1 - SSE ./ SST;
end
function dT = EvaluateTemperatureFromConversion(Alpha, T, InitialVelocity, PolyEaCoefficients, PolyACoefficients, fParameters)
R = 8.3144598;
TempEaEvaluation = polyval(PolyEaCoefficients, Alpha);
TempAEvaluation = exp(polyval(PolyACoefficients, TempEaEvaluation));
TempfEvaluation = SestakBerggren(Alpha, fParameters);
dT = InitialVelocity .* exp(TempEaEvaluation ./ (R .* T) - log(TempAEvaluation .* TempfEvaluation));
end


function predicted = getPredicted(results,options)
% Syntax:
%
% predicted = nb_dfmemlEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'Z')
        predicted = nb_ts();
    else

        indF  = 1:options(end).nFactors*max(options(end).nLags,5);
        alpha = results.smoothed.variables.data(:,indF)';
        Z     = results.Z(:,indF)*alpha;
        if ~isempty(results.S)
            Z = bsxfun(@times,Z,results.S);
        end
        Z         = results.C*results.W' + Z;
        vars      = strcat('Predicted_',options(end).observables);
        predicted = nb_ts(Z', 'Predicted', results.smoothed.variables.startDate,vars,false); 

    end

end

function predicted = getPredicted(results,options)
% Syntax:
%
% predicted = nb_tvpmfsvEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'Z')
        predicted = nb_ts();
    else

        indF  = 1:min(options(end).nFactors*max(options(end).nLags,5),size(results.Z,2));
        alpha = results.smoothed.variables.data(:,indF,end)';
        Z     = results.Z(:,indF,end)*alpha;
        if ~isempty(results.S)
            Z = bsxfun(@times,Z,results.S(:,:,end));
        end
        Z         = results.C(:,:,end)*results.W(:,:,end)' + Z;
        vars      = strcat('Predicted_',options(end).observables);
        predicted = nb_ts(Z', 'Predicted', results.smoothed.variables.startDate,vars,false); 

    end

end

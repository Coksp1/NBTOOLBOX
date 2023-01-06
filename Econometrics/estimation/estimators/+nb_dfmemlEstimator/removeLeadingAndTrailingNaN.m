function options = removeLeadingAndTrailingNaN(options)
% Syntax:
%
% options = nb_dfmemlEstimator.removeLeadingAndTrailingNaN(options)
%
% Description:
%
% Remove leading and trailing nans from dataset.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [test,indX]  = ismember(options.observables,options.dataVariables);
    if any(~test)
        error(['The following observables are not found in the data; ' toString(options.observables(~test))])
    end
    X         = options.data(options.estim_start_ind:options.estim_end_ind,indX);
    
    % Remove all rows with all nan values.
    isNaN     = isnan(X);
    keep      = ~all(isNaN,2);
    start     = find(keep,1,'first');
    finish    = find(keep,1,'last');
    
    % Adjust estimation sample
    if ~isempty(start)
        options.estim_start_ind = options.estim_start_ind + start - 1;
    end
    if ~isempty(finish)
        if finish < size(X,1)
            options.estim_end_ind = options.estim_start_ind + finish - 1;
        end
    end
    
end

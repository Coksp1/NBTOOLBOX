function options = applyCovidFilter(options,y)
% Syntax:
%
% options = nb_bVarEstimator.applyCovidFilter(options,y)
%
% Description:
%
% Apply covid filter, and return index of elements to include in
% estimation as a field to the prior option, i.e. elements set to true 
% should be kept during estimation. This index is empty, if the covidAdj
% option is empty.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Do we strip observations?
    indCovid  = nb_estimator.applyCovidFilter(options,y);

    % Assign the index to the prior options to make it available for all
    % estimation functions
    options.prior.indCovid = indCovid;

end

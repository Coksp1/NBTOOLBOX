function err = checkSteadyStateStatic(options,paramV,tol,ss,steady_state_exo)
% Syntax:
%
% err = nb_dsge.checkSteadyStateStatic(options,paramV,tol,ss)
%
% Description:
%
% Check the steady-state of a model solved with the NB Toolbox.
% 
% Input:
% 
% - options : See the estOptions property of the nb_dsge class.
%
% - paramV  : The value of the parameters of the model.
% 
% - tol     : The tolerance level. As a small positive number.
%
% - ss      : The steady-state values to test.
%
% Output:
% 
% - err     : If you ask for this output the error message will be returned
%             instead of thrown in this function.
%
% See also:
% nb_dsge.checkSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        steady_state_exo = [];
    end

    err = '';
    if isfield(options.parser,'stationaryEquations')
        eqs = [options.parser.stationaryEquations;options.parser.growthEquations];
    else
        eqs = options.parser.equations;
    end
    [varN,~,ssAll] = nb_dsge.getOrderingNB(options.parser,ss);
    if ~nb_isempty(steady_state_exo)
        % We have non-zero shocks in steady-state
        innov = fieldnames(steady_state_exo);
        for ii = 1:length(innov)
            ind        = strcmp(innov{ii},varN);
            ssAll(ind) = steady_state_exo.(innov{ii});
        end
    end
    test   = options.parser.eqFunction(ssAll,paramV);
    failed = abs(test) > tol | isnan(test);
    if any(failed)
        failed    = failed(1:length(eqs));
        failedEqs = eqs(failed);
        num       = 1:length(eqs);
        numStr    = strtrim(cellstr(int2str(num(failed)')));
        testStr   = strtrim(cellstr(num2str(test(failed))));
        failedEqs = strcat(failedEqs,' = ', testStr , '; (nr. ', numStr, ')');
        err       = [mfilename ':: The steady-state solution provided does not solve the static model of the following equations: \n\n'];
        for ii = 1:length(failedEqs)
            err = [err, failedEqs{ii}, '\n']; %#ok<AGROW>
        end
        
        if nargout == 0
            error('nb_dsge:steadyStateCheckFailed',err,'');
        end
    end
    
end

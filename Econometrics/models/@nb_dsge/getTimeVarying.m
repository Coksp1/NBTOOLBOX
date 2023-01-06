function [indTimeVarying,timeVarying,filterType] = getTimeVarying(options,parser,filterType)
% Syntax:
%
% [indTimeVarying,timeVarying,filterType] = 
%      nb_dsge.getTimeVarying(options,parser,filterType)
%
% Description:
%
% Get information on time-varying parameters.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    indTimeVarying = [];
    timeVarying    = [];
    if ~isempty(options.timeVarying)
        
        if any(filterType == [2,4])
            error([mfilename ':: Using the timeVarying option and at the same time ',...
                             'have break-points or a stochastic trend is not possible.'])
        end
        tvVars = options.timeVarying;
        if ~iscellstr(tvVars)
            error([mfilename ':: The timeVarying option must be a cellstr.'])
        end
        [testTV,locTV] = ismember(tvVars,options.dataVariables);
        if any(~testTV)
            error([mfilename ':: The variables given by the timeVarying input must be contained in data option. The following are missing; ' toString(tvVars(~testTV))])
        end 
        [indP,indTimeVarying] = ismember(tvVars,parser.parameters);
        if any(~indP)
            error([mfilename ':: You have specified the following parameter as time varying, ' toString(tvVars(~indP)) ', but they are not declared as parameters of the model.'])
        end
        timeVarying = options.data(options.estim_start_ind:options.estim_end_ind,locTV)';
        filterType  = 3;
        
    end
    
end

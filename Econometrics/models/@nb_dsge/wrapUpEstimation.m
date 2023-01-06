function obj = wrapUpEstimation(obj,res,estOpt)
% Syntax:
%
% obj = wrapUpEstimation(obj,res,estOpt)
%
% Description:
%
% Assign estimation output to object.
% 
% Input:
% 
% - obj    : An object of class nb_dsge.
%
% - res    : A struct with the estimation results of the assign object.
%
% - estOpt : A struct with the estimation options of the assign object.
% 
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_model_estimate.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    breakPoints = estOpt.parser.breakPoints;
    if ~nb_isempty(breakPoints)
        % Check for estimation of timing of break. If some are found we
        % correct the prior so that some later mathods work as they should,
        % e.g. sample, curvature, etc.
        for ii = 1:length(breakPoints)
            if breakPoints(ii).date ~= breakPoints(ii).initDate
                breakPInit = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).initDate));
                breakP     = strcat(breakPoints(ii).parameters,'_',toString(breakPoints(ii).date));
                [ind,loc]  = ismember(breakPInit,estOpt.prior(:,1));
                if any(ind)
                    estOpt.prior(loc(ind),1) = breakP(ind);
                end
                ind                 = strcmpi(['break_' toString(breakPoints(ii).initDate)],estOpt.prior(:,1));
                estOpt.prior{ind,1} = ['break_' toString(breakPoints(ii).date)];
                
                % Correct prior support accodingly
                diff                = breakPoints(ii).date - breakPoints(ii).initDate;
                [lb,ub]             = deal(estOpt.prior{ind,4}{:});
                estOpt.prior{ind,4} = {lb - diff,ub - diff};
                
            end
        end
        obj.options.prior = estOpt.prior;
    end
    estOpt.parser             = estOpt.oldParser;
    estOpt.parser.breakPoints = breakPoints;
    estOpt                    = nb_rmfield(estOpt,setdiff(fieldnames(obj.options),...
                                     {'data','recursive_estim','optimizer','prior'}));                          
    obj.estOptions = estOpt;
    obj.results    = res;
    obj            = setSolution(obj,struct());
    obj            = indicateResolve(obj);
                
end

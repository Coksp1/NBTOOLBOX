function histData = getHistory(obj,vars,date,~,~)
% Syntax:
%
% histData = getHistory(obj,vars,date,notSmoothed,type)
%
% Description:
%
% Get historical data
% 
% Input:
% 
% - obj         : A scalar nb_midas object, subclass of the 
%                 nb_model_generic class.
%
% - vars        : A cellstr with the variables to get. May include
%                 shocks/residuals. Only the variables found is returned, 
%                 i.e. no error is provided if not all variables is found.
%
% - date        : For recursive real-time estimated models the history may 
%                 change. This will give the correct vintage for a given
%                 recursion.
% 
% - notSmoothed : Just for generics. Not in use for the nb_midas class.
%
% - type        : Just for generics. Not in use for the nb_midas class.
%
% Output:
% 
% - histData : A nb_ts object with the historical data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        date = '';
    end
    
    if numel(obj)>1
        error([mfilename ':: This function only handles scalar nb_midas objects.'])
    end

    estOpt = obj.estOptions;
    if numel(estOpt) > 1 
        % Real-time forecast, so we need to find the
        % correct vintage of the historical data
        if isempty(date) || ~estOpt(end).real_time_estim
            estOpt    = estOpt(end);
        else
            freq      = obj.options.data.frequency/estOpt.increment;
            startObj  = nb_date.toDate(date,freq);
            startEst  = nb_date.toDate(estOpt(end).start_low,freq);
            startInd  = (startObj - startEst) + 1;
            endEstInd = [estOpt.end_low] + 1;
            indRec    = startInd == endEstInd;
            estOpt    = estOpt(indRec);
        end
    end
    [~,indY] = ismember(estOpt.dependent,estOpt.dataVariables);
    Y        = estOpt.data(estOpt.mappingDep,indY);  
    histData = nb_ts(Y,'',estOpt.estim_start_date_low,estOpt.dependent(1));
    
    warning('off','nb_ts:window:VariableNotFound');
    histData = window(histData,'','',vars);
    warning('on','nb_ts:window:VariableNotFound');
    
end

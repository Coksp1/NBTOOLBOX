function options = secureAllLags(options)
% Syntax:
%
% options = nb_olsEstimator.secureAllLags(options)
%
% Description:
%
% Secure that all lags are added to the data, as they are needed for
% forecasting, shock decomposition etc. later.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    numDep = length(options.dependent);
    pred   = cell(1,numDep);
    for kk = 1:length(options.dependent)
        pred{kk} = regexp(options.exogenous,[options.dependent{kk},'_lag[0-9]*'],'match');
    end
    pred = nb_nestedCell2Cell(pred);
    if ~isempty(pred)
        maxLag  = regexp(pred,'\d+$','match');
        maxLag  = max(str2num(char([maxLag{:}]'))); %#ok<ST2NM>
        depLags = nb_cellstrlag(options.dependent,maxLag-1);
        ind     = ~ismember(depLags,options.dataVariables);
        if any(ind)
            [~,indY]              = ismember(options.dependent,options.dataVariables);
            yFull                 = options.data(:,indY);
            depLData              = nb_mlag(yFull,maxLag-1);
            options.data          = [options.data,depLData(:,ind)];
            options.dataVariables = [options.dataVariables,depLags(ind)];
        end
    end
    
end

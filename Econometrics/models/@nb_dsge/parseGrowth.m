function g = parseGrowth(parameters,beta,unitRootVars,unitRootGrowth)
% Syntax:
%
% g = nb_dsge.parseGrowth(parameters,beta,unitRootVars,unitRootGrowth)
%
% Description:
%
% Get the value of the growth in the unit root variables.
% 
% See also:
% nb_dsge.stationarize, nb_dsge.solveBalancedGrowthPath
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    g = nan(length(unitRootGrowth),1);
    for ii = 1:length(unitRootGrowth)
        ind = strcmp(unitRootGrowth{ii},parameters);
        if any(ind)
            g(ii) = beta(ind);
        else
            g(ii) = str2double(unitRootGrowth{ii});
        end
    end

    test = isnan(g);
    if any(test)
        error([mfilename ':: Invalid growth rates given to the unit root variables; ' toString(unitRootVars(test))])
    end
    
end

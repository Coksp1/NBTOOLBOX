function [horizon,err] = getHorizon(shockProperties,numAntSteps,solution)
% Syntax:
% 
% [horizon,err] = nb_dsge.getHorizon(shockProperties,numAntSteps,solution)
%
% Description:
%
% Get the horizon of anticipation for each shock.
% 
% Wriiten by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the horizon of each shock
    err        = '';
    horizon    = nan(1,length(shockProperties));
    res        = solution.res(solution.activeShocks);
    ShockNames = {shockProperties.Name};
    for j = 1:numel(shockProperties)

        sj    = ShockNames{j};
        sj_id = find(strcmp(sj, res),1);
        if isempty(sj_id)
            err = [mfilename,':: shock ',sj,' is undeclared'];
            if nargout < 2
                error(err)
            else
                return    
            end
        end

        % Horizon
        hh = shockProperties(j).Horizon;
        if isnan(hh)
            hh = numAntSteps;
        elseif hh > numAntSteps
            err = [mfilename,':: Maximum horizon for shock ',sj,' (',int2str(hh),') exceeds the maximum anticipation horizon (',int2str(numAntSteps),')'];
            if nargout < 2
                error(err)
            else
                return    
            end
        end
        horizon(sj_id) = hh;

    end

end

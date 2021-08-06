function parser = addMultipliers(parser)
% Syntax:
%
% parser = nb_dsge.addMultipliers(parser)
%
% Description:
%
% Add multipliers to list of endogenous variables.
% 
% See also:
% nb_dsge.looseOptimalMonetaryPolicySolver, 
% nb_dsge.optimalMonetaryPolicySolver
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~nb_contains(parser.endogenous{end},'mult_')
        % Not yet added, so we add them know
        nMult                  = sum(parser.isMultiplier);
        num                    = 1:nMult;
        numS                   = strtrim(cellstr(int2str(num')));
        mult                   = strcat('mult_',numS)';
        parser.endogenous      = [parser.endogenous,mult];  
    end

end

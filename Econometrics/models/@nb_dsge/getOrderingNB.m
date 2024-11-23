function [order,type,ss] = getOrderingNB(parser,ss)
% Syntax:
%
% [order,type,ss] = nb_dsge.getOrderingNB(parser,ss)
%
% Description:
%
% Get ordering of jacobian and steady-state values when model is solved 
% with NB Toolbox.
% 
% Input:
% 
% - parser : Located at obj.estOptions.parser.
% 
% - ss     : Steady-state values of endogenous variables (Not including 
%            lead and lags).
%
% Output:
% 
% - order : See nb_dsge.getDerivOrder.
%
% - type  : See nb_dsge.getDerivOrder.
%
% - ss    : See nb_dsge.getDerivOrder.
%
% See also:
% nb_dsge.getDerivOrder
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    lcl  = parser.leadCurrentLag;
    endo = parser.endogenous;
    if isfield(parser,'isMultiplier')
        % Remove multipliers if model has been solve under optimal monetary
        % policy already.
        lcl  = lcl(~parser.isMultiplier,:);
        endo = endo(~parser.isMultiplier);
    end
    forward  = endo(lcl(:,1)');
    forward  = strcat(forward,'_lead');
    backward = endo(lcl(:,3)');
    backward = strcat(backward,'_lag');
    order    = [forward,endo,backward,parser.exogenous];
    if nargout > 1
        numExo = length(parser.exogenous);
        type   = [ones(size(forward)), zeros(size(endo)), -ones(size(backward)), 2*ones(1,numExo)];
        if nargout > 2
            if ~isempty(ss)
                ss = [ss(lcl(:,1));ss;ss(lcl(:,3));zeros(numExo,1)]; 
            end
        end
    end
        
end

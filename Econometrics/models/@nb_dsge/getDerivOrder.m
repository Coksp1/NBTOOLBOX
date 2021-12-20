function [order,type,ss] = getDerivOrder(obj)
% Syntax:
%
% [order,type,ss] = getDerivOrder(obj)
%
% Description:
%
% Get order of returned jacobian.
% 
% Input:
% 
% - obj   : An object of class nb_dsge.
% 
% Output:
% 
% - order : A cellstr with the order of the returned jacobian.
%
% - type  : Indicate what the derivative is take w.r.t:
%           >  1 : Leaded variables.
%           >  0 : Current variables.
%           > -1 : Lagged variables.
%           >  2 : Innovations.
%
% - ss    : The steady-state of the ordered variables. As a 1 x N double.
%           If model is not solved this will return [].
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isNB(obj)
        if ~isfield(obj.solution,'ss')
            [order,type] = nb_dsge.getOrderingNB(obj.estOptions.parser,[]);
            ss           = [];
        else
            [order,type,ss] = nb_dsge.getOrderingNB(obj.estOptions.parser,obj.solution.ss);
        end
    elseif isRise(obj)
        
        riseObj = obj.estOptions.riseObject; 
        if isempty(riseObj.solution)
            error([mfilename ':: The model must be solved before you can calculate the jacobian from a model using RISE'])
        end
        lcl         = riseObj.lead_lag_incidence.after_solve;
        the_leads   = lcl(:,1)>0;
        the_lags    = lcl(:,3)>0;
        endo        = obj.dependent.name;
        forward     = endo(the_leads);
        forward     = strcat(forward,'_lead');
        backward    = endo(the_lags);
        backward    = strcat(backward,'_lag');
        order       = [forward,endo,backward,obj.exogenous.name];
        if nargout > 2
            type    = [ones(size(forward)), zeros(size(endo)), -ones(size(backward)), 2*ones(1,obj.exogenous.number)];
            numExo  = obj.exogenous.number;
            ss      = full(riseObj.solution.ss{1});
            ss      = [ss(the_leads);ss;ss(the_lags);zeros(numExo,1)]; 
        end
        
    else
        error([mfilename ':: This is not yet implemented for model solved with Dynare.'])
    end
        
end

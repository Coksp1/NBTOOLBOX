function discount = setDiscount(discount,parameters,beta)
% Syntax:
%
% iscount = nb_dsge.setDiscount(discount,parameters,beta)
%
% Description:
%
% Assign parameter values to discount factors.
% 
% Input:
% 
% - discount   : See nb_dsge.help('discount')
%
% - parameters : A cellstr with the parameter names.
%
% - beta       : A double with the parameter values.
% 
% Output:
% 
% - discount   : Updated discount factors.
%
% See also:
% nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    for ii = 1:length(discount)
        if ~isempty(discount(ii).name)
            % Look for the parameter
            ind = strcmp(discount(ii).name,parameters);
            if ~any(ind)
                if isnumeric(discount(ii).eq)
                    eqStr = num2str(discount(ii).eq(:)');
                    error([mfilename ':: The discount factor applied to the equations ' eqStr,...
                                     ' cannot be found to be a parameter; ' discount(ii).name])
                else
                    error([mfilename ':: The discount factor applied to all equation ',...
                                     'cannot be found to be a parameter; ' discount(ii).name])
                end
            end
            discount(ii).value = beta(ind);
        end
    end

end

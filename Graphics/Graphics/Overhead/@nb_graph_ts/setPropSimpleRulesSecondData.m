function setPropSimpleRulesSecondData(obj,propertyName,propertyValue)
% Syntax:
% 
% setPropSimpleRulesSecondData(obj,propertyName,propertyValue)
% 
% Description:
% 
% Set the simpleRulesSecondData property of the nb_graph_ts class. This 
% method is used by the set method of nb_graph to set the 
% simpleRulesSecondData and do some additional housekeeping.
%
% See documentation NB Toolbox or type help('nb_graph_ts') for more
% on the properties of the class.
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts. 
% 
% - propertyName  : n x 1 char. Propertyname to set. (Should be 
%                 'simpleRulesSecondData' for expected behavior). 
%
% - propertyValue : Value to set the simpleRulesSecondData property to.
%
% Output:
%
% No actual output, but the input object simpleRulesSecondData property 
% will have been set to the new value.
%
% See also:
% set, nb_parseInputs
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(propertyValue) || isa(propertyValue,'dyn_ts')
        inputData          = propertyValue;
        obj.(propertyName) = nb_ts(inputData);
    else % nb_ts case. We have checked that its one of these three in 
         % nb_parseInputs. 
        obj.(propertyName) = propertyValue;
    end

end

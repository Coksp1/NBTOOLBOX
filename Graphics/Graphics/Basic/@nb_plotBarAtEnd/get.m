function propertyValue = get(obj,propertyName)
% Syntax:
% 
% propertyValue = get(obj,propertyName)
% 
% Description:
% 
% Get a property of an object of class nb_fanChart
% 
% Input:
% 
% - obj           : An object of class nb_fanChart
% 
% - propertyName  : A string with the propertyName 
% 
% Output:
% 
% - propertyValue : The value of the given property
%     
% Examples:
%
% propertyValue = obj.get('central');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~ischar(propertyName)
        error([mfilename ':: The propertyName must be a string.'])
    end

    switch lower(propertyName)

        case 'cdatabar'

            propertyValue = obj.cDataBar;

        case 'linestop'

            propertyValue = obj.lineStop;

        case 'barperiods'

            propertyValue = obj.barPeriods;

        otherwise

            propertyValue = get@nb_plot(obj,propertyName);

    end

end

function precision = interpretPrecision(precision)
% Syntax:
%
% precision = nb_estimator.interpretPrecision(precision)
%
% Description:
%
% Interpret the precision input to the print function of the different
% estimator packages.
% 
% Input:
% 
% - precision : The precision input to the different print functions.
% 
% Output:
% 
% - precision : The interpreded precision input.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(precision)
        precision = '%8.6f';
    else
        if ~ischar(precision)
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
        precision(isspace(precision)) = '';
        if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
           ~isstrprop(precision(end),'alpha')
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
    end
    
end

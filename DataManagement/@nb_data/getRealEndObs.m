function realEndObs = getRealEndObs(obj,type)
% Syntax:
%
% realEndObs = getRealEndObs(obj)
% realEndObs = getRealEndObs(obj,type)
%
% Description:
%
% Get the real end obs of the nb_data object. I.e the last 
% observation which is not nan or infinite. 
% 
% Input:
% 
% - obj           : An object of class nb_data
%
% - type          : Either 'any' (default) or 'all'.
% 
% Output:
% 
% - realEndData   : The last observation of the object which is not 
%                   nan or infinite. As a double
%
% Examples:
%
% realEndObs = obj.getRealEndObs();
% realEndObs = obj.getRealEndObs('all');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'any';
    end

    isFinite = isfinite(obj.data);
    if strcmpi(type,'all')
        isFinite = all(all(isFinite,2),3);
    else
        isFinite = any(any(isFinite,2),3);
    end
    first      = find(isFinite,1,'last');   
    realEndObs = obj.startObs + first - 1;

end

function obs = observations(obj,type)
% Syntax:
%
% obs = observations(obj,type)
%
% Description:
%
% Get all the observations of the nb_data object
% 
% Input:
% 
% - obj  : An object of class nb_data
%
% - type : A string. Either 'double' (default) or 'cellstr'.
% 
% Output:
% 
% - obs : Either a double or cellstr. 
%
% See also:
% nb_data
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'double';
    end

    switch type
        
        case 'double'
            
            obs = obj.startObs:obj.endObs;
            obs = obs';
            
        case 'cellstr'
            
            obs = strtrim(cellstr(int2str([obj.startObs:obj.endObs]'))); %#ok
            
        case 'cell'
            
            obs = obj.startObs:obj.endObs;
            obs = num2cell(obs');
            
        otherwise
            
            
    end


end

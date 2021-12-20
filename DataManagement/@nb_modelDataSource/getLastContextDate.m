function lastContextDate = getLastContextDate(obj)
% Syntax:
%
% lastContextDate = getLastContextDate(obj)
%
% Description:
%
% Get last context date from the data source.
% 
% Input:
% 
% - obj  : An object of class nb_modelDataSource.
% 
% Output:
% 
% - lastContextDate : A one line char with the last context date.
%                     One the format 'yyyymmdd' or 'yyyymmddhhnnss'.
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    lastContextDate = getLastContextDate(obj.source);
    
end

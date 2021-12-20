function data = fetch(obj)
% Syntax:
%
% data = fetch(obj)
%
% Description:
%
% Fetch all the data of the data source.
% 
% Input:
% 
% - obj  : An object of class nb_modelDataSource.
% 
% Output:
% 
% - data : An object of class nb_ts storing the data fetched from  
%          the data source (Includes both new and old contexts/
%          vintages).
%
% See also:
% nb_modelDataSource.update, nb_modelDataSource.fetchLastContext
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    data = getTS(obj.source,'',obj.variables,obj.calendar);
    
end

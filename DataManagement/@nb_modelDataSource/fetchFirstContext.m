function data = fetchFirstContext(obj)
% Syntax:
%
% data = fetchFirstContext(obj)
%
% Description:
%
% Fetch first context from the data source.
% 
% Input:
% 
% - obj  : An object of class nb_modelDataSource.
% 
% Output:
% 
% - data : An object of class nb_ts storing the data fetched from  
%          the data source. With size nObs x nVar.
%
% See also:
% nb_modelDataSource.update, nb_modelDataSource.fetch
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    data = getFirstContext(obj.source);
    
end

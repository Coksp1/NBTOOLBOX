function dataTS = getData(obj)
% Syntax:
%
% dataTS = getData(obj)
%
% Description:
%
% Get the data of the object as a nb_ts object.
% 
% Input:
% 
% - obj    : An object of class nb_modelDataSource.
% 
% Output:
% 
% - dataTS : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dataTS = obj.data;

end

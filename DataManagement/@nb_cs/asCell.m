function cellMatrix = asCell(obj,page)
% Syntax:
%
% cellMatrix = asCell(obj,page)
%
% Description:
%
% Return the nb_cs objects data as a cell matrix. 
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - page       : Which pages should be transformed to a cell. Must 
%                be a double (vector) with the indicies.
% 
% Output:
% 
% - cellMatrix : The objects data transformed to a cell. (With 
%                types and variable names)
% 
% Examples:
% 
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% cellMatrix = obj.asCell();
%
% Written by Kenneth S. Paulsen              

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        page = 1:obj.numberOfDatasets;
    end

    if isa(obj.data,'nb_distribution')
        d = reshape({obj.data.name},[obj.numberOfTypes,obj.numberOfVariables,obj.numberOfDatasets]);
    else
        d = num2cell(obj.data(:,:,page));
    end
    
    nPage      = length(page);
    corner     = {'Types'};
    corner     = corner(:,:,ones(1,nPage));
    vars       = obj.variables(:,:,ones(1,nPage));
    typess     = obj.types';
    typess     = typess(:,:,ones(1,nPage));
    cellMatrix = [corner, vars; typess, d];
    
end

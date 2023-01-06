function cellMatrix = asCell(obj,page,strip)
% Syntax:
%
% cellMatrix = asCell(obj,page,strip)
%
% Description:
%
% Return the nb_bd objects data as a cell matrix. 
% 
% Input:
% 
% - obj        : An object of class nb_bd
% 
% - page       : Which pages of the expanded dataset should be transformed 
%                to a cell. Must be a double (vector) with the indicies.
% 
% - strip      : Set to false to not strip all the nan observations.
%
% Output:
% 
% - cellMatrix : The objects data transformed to a cell. (With 
%                types and variable names)
% 
% Examples:
% 
% obj        = nb_bd([2,2],'test','2000Q1',{'Var1','Var2'});
% cellMatrix = obj.asCell();
%
% Written by Per Bjarne Bye              

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        strip = true;
        if nargin < 2
            page = 1:obj.numberOfDatasets;
        end
    end
    
    if isa(obj.data,'nb_distribution')
        cellData = reshape({obj.data.name},[obj.numberOfTypes,obj.numberOfVariables,obj.numberOfDatasets]);
    else
        data = getFullRep(obj);
        if strip
            isNaN = all(all(isnan(data),2),3);
            data  = data(~isNaN,:,:);
        end
        cellData = num2cell(data);
    end
   
    nPage  = length(page);
    corner = {'bd'};
    corner = corner(:,:,ones(1,nPage));
    vars   = obj.variables(:,:,ones(1,nPage));
    dates  = obj.startDate.toDates(0:obj.numberOfObservations - 1,'default',obj.frequency);
    if strip
        dates = dates(~isNaN);
    end
    dates      = dates(:,:,ones(1,obj.numberOfDatasets));
    cellMatrix = [corner, vars; dates, cellData];
    
end

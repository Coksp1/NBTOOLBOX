function cellMatrix = asCell(obj,page)
% Syntax:
%
% cellMatrix = asCell(obj,page)
%
% Description:
%
% Return the nb_cell objects data as a cell matrix. 
% 
% Input:
% 
% - obj        : An object of class nb_cell
% 
% - page       : Which pages should be transformed to a cell. Must 
%                be a double (vector) with the indicies.
% 
% Output:
% 
% - cellMatrix : The objects data transformed to a MATLAB cell.
% 
% Written by Kenneth S. Paulsen              

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        page = 1:obj.numberOfDatasets;
    end

    cellMatrix = obj.cdata(:,:,page);

end

function cellMatrix = asCellForMPRReport(obj,roundoff)
% Syntax:
%
% cellMatrix = asCellForMPRReport(obj,roundoff)
%
% Description:
%
% Return the nb_cs objects data as a cell matrix, on the 
% MPR publishing format
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - roundoff   : 1 if you want to round off to 2 decimals, 0 
%                otherwise. 1 is default.
% 
% Output:
% 
% - cellMatrix : The objects data transformed to a cell. (With 
%                types and variable names) Only the first page is 
%                returned. Look very much like an excel 
%                spreadsheet.
%
% Examples:
%
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% cellMatrix = asCellForMPRReport(obj,1);
% 
% Written by Kenneth S. Paulsen              

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        roundoff = 1;
    end

    d          = obj.data(:,:,1);
    if roundoff
        d = round(d*100)/100;
    end
    cellMatrix = [{''} obj.variables; obj.types' num2cell(d)];

end

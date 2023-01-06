function cellMatrix = asCellForMPRReport(obj,roundoff)
% Syntax:
%
% cellMatrix = asCellForMPRReport(obj,roundoff)
%
% Description:
%
% Return the nb_cell objects data as a cell matrix, on the 
% MPR publishing format
% 
% Input:
% 
% - obj        : An object of class nb_cell
% 
% - roundoff   : 1 if you want to round off to 2 decimals, 0 
%                otherwise. 1 is default.
% 
% Output:
% 
% - cellMatrix : The objects data transformed to a cell. Only the first 
%                page is returned. Look very much like an excel 
%                spreadsheet.
%
% Written by Kenneth S. Paulsen              

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        roundoff = 1;
    end

    d = obj.data(:,:,1);
    if roundoff
        d = round(d*100)/100;
    end
    obj.data   = d; % This will update the cdata property as well
    cellMatrix = obj.cdata(:,:,1);

end

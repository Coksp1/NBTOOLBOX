function cellMatrix = asCellForMPRReport(obj,roundoff)
% Syntax:
%
% cellMatrix = asCellForMPRReport(obj,roundoff)
%
% Description:
%
% Return the data of the object as a cell matrix, which is rounded 
% off to two decimals and striped
% 
% Input:
% 
% - obj      : An object of class nb_ts
% 
% - roundoff : Give the number of wanted decimals. If empty no round-off
%              will be done. Default is 2, i.e. 2.02. 0 decimals is also
%              possible. Must be an integer larger than or equal to 0, or 
%|             empty (no round-off).
% 
% Output:
% 
% - cellMatrix : The objects data transformed to a cell.
%                
% Examples:
%
% cellMatrix = obj.asCellForMPRReport();
% cellMatrix = obj.asCellForMPRReport(0);
%
% See also:
% asCell
% 
% Written by Kenneth S. Paulsen              

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        roundoff = 2;
    end

    if ~isnumeric(roundoff)
        roundoff = [];
    end
    
    d          = obj.data;
    ind        = all(all(isnan(d),2),3);
    d          = d(~ind,:,:);
    if ~isempty(roundoff)
        factor = 10^roundoff;
        d      = round(d*factor)/factor;
    end 
    dates      = obj.startDate.toDates(0:obj.numberOfObservations - 1,'xls',obj.frequency,0);
    dates      = dates(~ind,1);
    cellMatrix = [{''}, obj.variables; dates, num2cell(d)];

end

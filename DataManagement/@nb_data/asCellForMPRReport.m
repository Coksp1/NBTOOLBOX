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
% - obj      : An object of class nb_data
% 
% - roundoff : 1 if you want to round off to 2 decimals, 0 
%              otherwise. 1 is default.
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
        roundoff = 1;
    end

    d          = obj.data;
    ind        = all(all(isnan(d),2),3);
    d          = d(~ind,:,:);
    if roundoff
        d = round(d*100)/100;
    end
    obs        = obj.startObs:obj.endObs;
    obs        = obs(:);
    obs        = obs(~ind,1);
    cellMatrix = [{''}, obj.variables; num2cell(obs), num2cell(d)];

end

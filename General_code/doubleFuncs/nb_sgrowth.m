function out = nb_sgrowth(data,horizon)
% Syntax:
%
% out = nb_sgrowth(data,horizon)
%
% Description:
%
% Calculates smoothened 12 or 6 months growth.
% x(*) = ((x13+x14+x15)/(x1+x2+x3)-1)*100 
% x(*) = ((x7+x8+x9)/(x1+x2+x3)-1)*100 
%
% Note: Works only for monthly data.
%
% Based on Anne Sofie Jores data transformation code.
%
% Input:
%
% - data    : As a double r*c*p matrix with monthly observations.
%
% - horizon : Either 1 or 2, depending on the frequency you want your
%             growth to be caluclated over. 1 is annual and 2 i semi-annual.
%
% Output:
% - out    : A r*c*p double matrix.
% 
% See also:
% nb_ts.sgrowth
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        horizon = [];
    end
    if isempty(horizon)
        horizon = 1;
    end
    switch horizon
        case 1          
            start = 15;
            d1    = 13;
            d2    = 14;
            d3    = 12;
        case 2          
            start = 9;
            d1    = 7;
            d2    = 8;
            d3    = 6;
    end

    [r,c,p]         = size(data);
    out             = nan(r,c,p);
    out(start:end,:,:) = ((data(start:end,:,:) + data(d2:end-1,:,:)...
                    + data(d1:end-2,:,:))./(data(1:end-d2,:,:)...
                    + data(2:end-d1,:,:) + data(3:end-d3,:,:)) - 1)*100;    

end

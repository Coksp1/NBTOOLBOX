function [temp, xTicks,dates] = stripData(data,xTicks,dates)
% Syntax:
%
% [temp, xTicks,dates] = nb_graph.stripData(data,xTicks,dates)
%
% Description:
%
% Strip missing values and update the x-tick marks accordingly
%
% Input:
%
% - data   : A double containing the data to strip
%
% - xTicks : A double with the location of the x-axis tick marks in
%            dates input.
%
% - dates  : A cellstr with the dates matching the data
% 
% Output:
%
% - temp   : The stripped data
%
% - xTicks : The xTicks updated, given the possibility that date 
%            which the x-axis tick label is representing is 
%            stripped from the dates input. 
%
% - dates  : A stripped dates, as a cellstr
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        xTicks = '';
        dates  = '';
    end

    % Strip data
    temp            = data;
    isNaN           = all(isnan(temp),2);
    temp(isNaN,:)   = [];

    if ~isempty(dates)
        % Strip dates
        dates = dates(~isNaN);

        % Correct x-ticks
        xti    = xTicks;
        locNaN = find(isNaN);
        for ii = 1:size(xti,1)
            remPer = sum(locNaN < xti(ii));

            if remPer > 0
                xti(ii) = xti(ii) - remPer;
            end
        end

        xTicks = xti;
    end

end

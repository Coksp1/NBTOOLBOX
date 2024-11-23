function ylimit = findLimitsAlgo(dataLow,dataHigh,method,fig)
% Syntax:
%
% ylimit = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,method,fig)
%
% Description:
%
% A static method of the nb_plotHandle class.
%
% Figure out the limits of prepared data by the subclasses of this
% class
%
% Input:
%
% - dataLow  : A double with the lowest values to plot
%
% - dataHigh : A double with the highest values to plot
%
% - method   : The method to use when finding the y-axis limits.
%
%              > 1:  Uses the floor and ceil methods. (Give problem 
%                    when graphing small number)
%              > 2:  Add some space in both direction of the 
%                    y-axis. (The limits will seldom be nice 
%                    numbers.)
%              > 3:  Uses the submethod findClosestNiceNumber of 
%                    the class to decide on the limits. (Also this 
%                    method have can have problems with data which 
%                    is not symmetric around the zero line.) 
%              > 4 : Uses the MATLAB algorithm for finding the 
%                    axis limits.
%
% Output:
%
% - ylimit : The y-axis limits. Given by a 1 x 2 double.
%            [lowerlimit upperlimit]
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        fig = gcf;
    end

    switch method

        case 1 % Closest integer approch

            ylimit     = [floor(min(dataLow)) ceil(max(dataHigh))];
            ylimTotMin = min(ylimit);
            ylimTotMax = max(ylimit);
            ylimit     = [ylimTotMin, ylimTotMax];

        case 2 % Find the min and max value and add some space 
               % in both direction

            ylimit     = [min(dataLow) max(dataHigh)];
            ylimTotMin = min(ylimit);
            ylimTotMax = max(ylimit);
            ylimit     = [ylimTotMin - (ylimTotMax-ylimTotMin)/10,  ylimTotMax + (ylimTotMax-ylimTotMin)/10];

        case 3 % Uses the function findClosestNumber method to 
               % find the limits

            ylimit     = [min(dataLow) max(dataHigh)];
            ylimTotMin = min(ylimit);
            ylimTotMax = max(ylimit); 
            ylimTotMin = nb_plotHandle.findClosestNiceNumber(ylimTotMin, ylimTotMax - ylimTotMin, 0);
            ylimTotMax = nb_plotHandle.findClosestNiceNumber(ylimTotMax, ylimTotMax - ylimTotMin, 1);
            ylimit     = [ylimTotMin, ylimTotMax];

        case 4 % Let matlab find the limits

            ax = axes('parent',fig);
            plot(ax,[min(dataLow(isfinite(dataLow))) max(dataHigh(isfinite(dataLow)))]);
            ylimit = get(ax,'yLim');
            delete(ax);
            if diff(ylimit) < 1e-10
                ylimit = [-1,1];
            end

        otherwise

            error([mfilename ':: The only possible values of the property ''findAxisLimitMethod'' is 1,2,3 or 4.'])

    end 

end

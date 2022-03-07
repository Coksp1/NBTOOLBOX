function [beforeSplit,afterSplit] = splitData(data,splitIndex,corr)
% Syntax:
%
% [beforeSplit,afterSplit] = nb_graph.splitData(data,splitIndex,corr)
%
% Description:
%
% Split data given a index.
%
% Input:
%
% - data        : A double
%
% - splitIndex  : The index of where to split the input data.
% 
% Output:
%
% - beforeSplit : A double with the data up an including the 
%                 splitIndex. (Keeps the size of the input data. 
%                 I.e. will append nan values after the 
%                 splitIndex.)
%
% - afterSplit  : A double with the data from and including the 
%                 splitIndex. (Keeps the size of the input data. 
%                 I.e. will add nan values before the splitIndex.)
%
% - corr        : If 1 the aftersplit will be the data from but and
%                 including the splitIndex + 1.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        corr = 0;
    end

    numberOfVarToPlot = size(data,2);
    numberOfPeriods   = size(data,1);

    beforeSplit = [data(1:splitIndex,:); nan(numberOfPeriods - splitIndex,numberOfVarToPlot)];
    if corr
        afterSplit  = [nan(splitIndex,numberOfVarToPlot); data(splitIndex+1:end,:)];
    else
        afterSplit  = [nan(splitIndex - 1,numberOfVarToPlot); data(splitIndex:end,:)];
    end

end

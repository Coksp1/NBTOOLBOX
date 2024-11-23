function obj = window(obj,startDateWin,endDateWin,pages)
% Syntax:
%
% obj = window(obj,startDateWin,endDateWin,pages)
%
% Description:
%
% Narrow down window of the data of the nb_math_ts object
% 
% Input:
% 
% - obj          : An object of class nb_math_ts
% 
% - startDateWin : The new wanted start date of the data of the
%                  object. Must be a string on the format; 
%                  'yyyyQq', 'yyyyMmm' or 'yyyy'. If empty, 
%                  i.e. '', nothing is done to the start date of 
%                  the data. 
%
%                  Can also be an object which is a subclass of
%                  the nb_date class.
% 
% - endDateWin   : The new wanted end date of the data of the 
%                  object. Must be a string on the format.
%                  'yyyyQq', 'yyyyMmm' or 'yyyy'. If empty, 
%                  i.e. '', nothing is done to the end date of the 
%                  data.
%
%                  Can also be an object which is a subclass of
%                  the nb_date class.
% 
% - pages        : A numerical index of the pages you want to keep.
%                  E.g. if you want to keep the first 3 datasets
%                  (pages of the data) of the object. And the 
%                  number of datasets of the object is larger than
%                  3. You can use; 1:3. If empty all pages is kept.
% 
%                  I.e. obj = obj.window('','',{},1:3)
% 
% Output:
% 
% - obj          : An nb_math_ts object where the datasets of the 
%                  object is narrowed down to the specified window.
%         
% Examples:
%
%  obj = nb_math_ts(ones(10,2,2),'2012Q1');
%  obj = obj.window('2012Q2')
%  obj = obj.window('','2013Q4')
%  obj = obj.window('','',1)
%
% See also:
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        pages = [];
        if nargin < 3
            endDateWin = '';
            if nargin < 2
                startDateWin = '';
            end
        end
    end

    [startDateWin,endDateWin,startInd,endInd,pages] = getWindow(obj,startDateWin,endDateWin,pages);

    % Give the data properties
    obj.data      = obj.data(startInd:endInd,:,pages);
    obj.startDate = startDateWin;
    obj.endDate   = endDateWin;

end

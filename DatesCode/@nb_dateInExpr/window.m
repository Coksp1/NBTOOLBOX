function obj = window(obj,~,endDateWin,~)
% Syntax:
%
% obj = window(obj,startDateWin,endDateWin,pages)
%
% Description:
%
% Narrow down window
% 
% Input:
% 
% - obj          : An object of class nb_dateInExpr
% 
% - startDateWin : Any
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
% - pages        : Any
% 
% Output:
% 
% - obj          : An object of class nb_dateInExpr
%         
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        endDateWin = '';
    end

    if ~isempty(endDateWin)
        endDateWin = nb_date.toDate(endDateWin,  obj.date.frequency);
        if endDateWin < obj.date
            obj.date = endDateWin;
        end
    end
    
end

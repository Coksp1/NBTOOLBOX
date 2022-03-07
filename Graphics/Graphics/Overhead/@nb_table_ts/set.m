function set(obj,varargin)
% Syntax:
%
% set(obj, varargin)
%
% Description:
%
% Set properties of the nb_table_ts class
% 
% Input:
% 
% - varargin : Property name property value pairs.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    setProps = set@nb_table_data_source(obj,varargin{:});

    startSet = any(strcmpi('startTable',setProps));
    if startSet
        obj.manuallySetStartTable = 1;
    end

    endSet   = any(strcmpi('endTable',setProps));
    if endSet
        obj.manuallySetEndTable = 1;
    end
    
end

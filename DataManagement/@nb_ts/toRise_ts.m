function data_ts = toRise_ts(obj,type)
% Syntax:
%
% data_ts = toRise_ts(obj)
% data_ts = toRise_ts(obj,'struct')
%
% Description:
%
% Transform from an nb_ts object to an RISE ts object, or a struct
% of rise ts object representing each variable (Where the pages
% are added as dimension 2. I.e. the input to the data property
% of the rise_generic object).
% 
% Input: 
% 
% - obj       : An object of class nb_ts
%
% - type      : Either 'struct' or 'object'.
%   
% Output:
% 
% - data_ts   : An object of class ts or a struct of ts objects
%               
% Examples:
% 
% ts = obj.toRise_ts();
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'object';
    end
    
    sDate = toString(obj.startDate);
    if strcmpi(type,'struct')
        
        data_ts = struct();
        data   = obj.data;
        for ii = 1:obj.numberOfVariables
            data_ts.(obj.variables{ii}) = ts(sDate,permute(data(:,ii,:),[1,3,2]));
        end
        
    else
        
        data_ts = ts(sDate,obj.data,obj.variables);
        
    end
    
end

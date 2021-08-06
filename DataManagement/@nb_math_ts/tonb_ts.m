function obj = tonb_ts(obj,variables,dataName)
% Syntax:
%
% obj = tonb_ts(obj,variables,dataName)
%
% Description:
%
% Convert the nb_math_ts object to an nb_ts object
% 
% Input:
% 
% - obj       : An object of class nb_math_ts
% 
% - variables : The variable names of the created nb_ts object.
% 
% - dataName  : The name of the dataset(s) of the created nb_ts 
%               object. Either a string or an cellstr. When given 
%               as cellstr it must match the number of pages of the
%               provided nb_math_ts object. If not given default 
%               name(s) will be used.
% 
% Output:
% 
% - obj       : An object of class nb_ts
% 
% Examples:
% 
% obj  = nb_math_ts([2,2;2,2],'2012Q1');
% obj1 = tonb_ts(obj,{'Var1','Var2'},'test')
% obj2 = tonb_ts(obj,{'Var1','Var2'})
%
% See also:
% nb_ts
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    if nargin < 3
        dataName = '';
    end

    obj = nb_ts(obj.data,dataName,obj.startDate,variables);

end

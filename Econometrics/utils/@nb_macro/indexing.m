function obj = indexing(obj,index)
% Syntax:
%
% obj = indexing(obj,index)
%
% Description:
%
% Use this method to index the arrays that the nb_macro object represent.
% 
% Input:
% 
% - obj   : An object of nb_macro.
%
% - index : A numerical array of integers. E.g. 5, 1:4, [1,3], [1,3:5]
% 
% Output:
% 
% - obj   : An object of nb_macro.
%
% Examples:
%
% m = nb_macro('I','DE');
% m = indexing(m,2)
%
% m = nb_macro('I2',{'A','B','C','D'});
% m = indexing(m,1:3)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isscalar(index) && iscellstr(obj.value)
        obj.value = obj.value{index};
    else
        obj.value = obj.value(index);
    end
    
end

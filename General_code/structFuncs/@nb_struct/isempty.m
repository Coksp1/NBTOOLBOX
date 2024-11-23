function ret = isempty(obj)
% Syntax:
%
% ret = isempty(obj)
%
% Description:
%
% Check if the nb_struct object is empty.
% 
% Input:
% 
% - obj : An object of class nb_struct.
% 
% Output:
% 
% - Same output as the isempty function of a normal MATLAB struct.
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = isempty(fieldnames(obj.s));

end

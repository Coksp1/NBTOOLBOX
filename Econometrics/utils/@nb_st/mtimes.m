function obj = mtimes(obj,another)
% Syntax:
%
% obj = mtimes(obj,another)
%
% Description:
%
% Times operator (*), which is the same as using .*.
% 
% Input:
% 
% - obj     : A scalar number or a nb_st object.
%
% - another : A scalar number or a nb_st object.
% 
% Output:
% 
% - obj     : An object of class nb_stParam or nb_stTerm.
%
% See also:
% nb_stTerm, nb_stParam, nb_st.times
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj = times(obj,another);

end

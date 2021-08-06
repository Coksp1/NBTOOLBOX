function obj = mrdivide(obj,another)
% Syntax:
%
% obj = mrdivide(obj,another)
%
% Description:
%
% Right division operator (/), which is the same as using ./.
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
% nb_stTerm, nb_stParam, nb_st.rdivide
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = rdivide(obj,another);

end

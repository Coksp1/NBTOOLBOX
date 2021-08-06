function obj = mpower(obj,another)
% Syntax:
%
% obj = mpower(obj,another)
%
% Description:
%
% Power operator (^), which is the same as using .^.
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
% nb_stTerm, nb_stParam, nb_st.power
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = power(obj,another);

end

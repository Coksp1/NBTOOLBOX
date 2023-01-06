function obj = set2Value(obj,func,value)
% Syntax:
%
% obj = set2Value(obj,func,value)
%
% Description:
%
% Set all values applying to the restriction given by the input func to
% the provided value.
% 
% Input:
% 
% - obj   : An object of class nb_math_ts.
% 
% - func  : A function handle that takes in a double with size M x N x P
%           and return a logical with same size.
%
% - value : A scalar double.
%
% Output:
% 
% - obj : An object of class nb_math_ts.
%
% Examples:
%
% obj = nb_math_ts.rand('2000',10,1) - 0.5;
% obj = set2Value(obj,@(x)x<0,0)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(func,'function_handle')
        error('The func input must be a function handle.')
    end
    if ~nb_isScalarNumber(value)
        error('The vlue input must be a scalar number.')
    end
    obj.data(func(obj.data)) = value;

end

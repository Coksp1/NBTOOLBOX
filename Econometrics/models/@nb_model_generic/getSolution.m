function value = getSolution(obj,type)
% Syntax:
%
% [obj,out,data_nb_ts] = callNBFilter(obj,inputs)
%
% Description:
%
% Return the shock impact matrix with row and column names
% 
% Input:
%
% - obj  : An object of class nb_model_generic
%
% - type : Type of matrix to return. One of:
%          > 'A' : Transition matrix.
%          > 'B' : Impact of exogenous matrix.
%          > 'C' : Impact of shocks matrix.
%
% See also:
% nb_dsge.filter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'A';
    end
    switch lower(type)
        case 'a'
            if isfield(obj.solution,'A')
                value = [{'A'}, obj.solution.endo;
                         obj.solution.endo', num2cell(obj.solution.A)];
            else
                value = [];
            end
        case 'b'
            if isfield(obj.solution,'B')
                value = [{'B'}, obj.solution.exo;
                         obj.solution.endo', num2cell(obj.solution.B)];
            else
                value = [];
            end
        case 'c'
            if isfield(obj.solution,'C')
                value = [{'C'}, obj.solution.res;
                         obj.solution.endo', num2cell(obj.solution.C)];
            else
                value = [];
            end
        otherwise
            error([mfilename ':: Cannot return the solution for matrix of type ' type '.'])
    end
    
end

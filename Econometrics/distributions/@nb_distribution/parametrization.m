function [obj, params] = parametrization(me,v,dist,lb,ub,s,k,mo)
% Syntax:
%
% obj = nb_distribution.parametrization(m,v,distribution)
% obj = nb_distribution.parametrization(m,v,distribution,lb,ub)
% obj = nb_distribution.parametrization(m,v,distribution,lb,ub,s,k,mo)
%
% Description:
%
% Depricated method. See nb_distribution.parameterization instead.
% 
% See also:
% nb_distribution.parameterization
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        mo = [];
        if nargin < 7
            k = [];
            if nargin < 6
                s = [];
                if nargin < 5
                    ub = [];
                    if nargin < 4
                        lb = [];
                    end
                end
            end
        end
    end
    
    [obj, params] = nb_distribution.parameterization(me,v,dist,lb,ub,s,k,mo);
    
end

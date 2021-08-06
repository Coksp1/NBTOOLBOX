function [i,j,v] = find(A)
% Syntax:
%
% [i,j,v] = find(A)
%
% Description:
%
% Find.
%
% This function does not support all use cases of find.
% 
% Written by SeHyoun Ahn, Oct 2017

    val = getvalues(A);
    der = getderivs(A);
    if issparse(val)
        [i,j,retval] = find(val);
        m            = size(val,1);
        retder       = der((j-1)*m + i, :);
        v            = myAD(retval,retder);
    else
        error('find is only supported for input in sparse representation');
    end
    
end

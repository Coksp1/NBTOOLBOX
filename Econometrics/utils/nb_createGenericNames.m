function [out,outS,inS,reorder] = nb_createGenericNames(in,generic)
% Syntax:
%
% [out,outS,inS,reorder] = nb_createGenericNames(in,generic)
%
% Description:
%
% Create generic names index by integers, e.g. {'x(1)';'x(2)'}
% 
% Input:
% 
% - in      : A cellstr with the original names.
%
% - generic : The generic name, e.g. 'x'.
% 
% Output:
% 
% - out     : A cellstr. See description.
%
% - outS    : in is sorted and out is index by the reordering.
%
% - inS     : The sorted version of in.
%
% - reorder : Reordering index.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    n    = length(in);
    num  = 1:n;
    numS = strtrim(cellstr(int2str(num')));
    out  = strcat(generic,'(',numS ,')');
    
    if nargout > 1
        [inS,reorder] = sort(in);
        outS          = out(reorder);
    end
    
end

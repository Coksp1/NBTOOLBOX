function c = nb_union(varargin)
% Syntax:
%
% c = nb_union(varargin)
%
% Description:
%
% Extension of the MATLAB function union, i.e. handles more than two
% inputs to union.
% 
% Input:
% 
% - varargin : Any type of input you can give to the two first inputs to
%              the union function.
% 
% Output:
% 
% - c        : The elements found in some inputs. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    c = varargin{1};
    for ii = 2:length(varargin)
        c = union(c,varargin{ii});
    end
 
end
        
    

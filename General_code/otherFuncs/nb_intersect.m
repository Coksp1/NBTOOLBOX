function c = nb_intersect(varargin)
% Syntax:
%
% c = nb_intersect(varargin)
%
% Description:
%
% Extension of the MATLAB function intersect, i.e. handles more than two
% inputs to intersect.
% 
% Input:
% 
% - varargin : Any type of input you can give to the two first inputs to
%              the intersect function.
% 
% Output:
% 
% - c        : The unique elements found in all inputs. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    c = varargin{1};
    for ii = 2:length(varargin)
        c = intersect(c,varargin{ii});
    end
 
end
        
    

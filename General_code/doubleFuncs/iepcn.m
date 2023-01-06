function dout = iepcn(DX,X,periods)
% Syntax:
%
% dout = iepcn(DX,X,periods)
%
% Description:
%
% Construct indicies based on inital values and series which 
% represent the series growth. Inverse of exact percentage growth, 
% i.e. the inverse method of the epcn method of the double class.
%
% Input:
%
% - din     : A double matrix with dimensions [r,c,p].
%
% - t       : A double matrix with dimensions [r,c,p].
% 
% - periods : The number of periods the din has been growthed over.
%
% Output:
% 
% - dout    : A double matrix with dimensions [r,c,p].
%
% See also: 
% egrowth, iegrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 1;
    end
    dout = iegrowth(DX/100,X,periods);
    
end


function demean = nb_demean(data,dim)
% Syntax:
%
% demean = nb_demean(data,dim)
%
% Description:
%
% - Demeans data along the dimension you choose.
%
% Input:
% 
% - data : A r*c*p double matrix
%
% - dim  : A double corresponding to the dimension you want to take the
%          average over. Default is 1.
%
% Output:
% 
% - demean : A r*c*p double matrix.
%
% See also:
% nb_subAvg, nb_subSum.
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = [];
    end
    if isempty(dim)
        dim = 1;
    end
    
    demean = data - nanmean(data,dim);

end

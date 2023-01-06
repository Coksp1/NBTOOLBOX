function methods = getMethods()
% Syntax:
%
% methods = getMethods()
%
% Description:
%
% Get a list of the supported methods of the nb_solve class.
%
% Output:
% 
% - methods : A cellstr with the supported methods of the nb_solve class.
%
% See also:
% nb_solve.call, nb_solve.optimset
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    methods = {'newton','steffensen','steffensen2','broyden','sane','dfsane','ypl'};

end

function obj = dealZeros(obj,nPar)
% Syntax:
%
% obj = dealZeros(obj,nPar)
%
% Description:
%
% Initialize the bees to the trivial solution.
% 
% Input:
% 
% - obj  : A vector of nb_beeSolver objects.
% 
% - nPar : Number of values to find the solution of.
%
% Output:
% 
% - obj  : A vector of nb_beeSolver objects.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [obj.tested] = deal(zeros(nPar,1));
    
end

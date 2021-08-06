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
% Written by Kenneth S�terhagen Paulsen
    
% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    [obj.tested] = deal(zeros(nPar,1));
    
end

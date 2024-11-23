function X = nb_monteCarloSim(draws,lb,ub,method)
% Syntax:
%
% X = nb_monteCarloSim(draws,numVar,method)
%
% Description:
%
% Make draws for monte carlo integration or other usch application.
% 
% Input:
% 
% - draws  : The number of draws from the N-th uniform cube.
%
% - lb     : A 1 x N double with the lower bounds.
%
% - ub     : A 1 x N double with the upper bounds.
% 
% - method : > 'latin'  : Uses nb_latinHypercubeSim.
%            > 'sobol'  : Uses sobolset (part of the MATLAB statistics 
%                         package).
%            > 'halton' : Uses haltonset (part of the MATLAB statistics 
%                         package).
% 
% Output:
% 
% - X      : As a draws x N double.
%
% See also:
% nb_latinHypercubeSim
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    lb     = lb(:)';
    ub     = ub(:)';
    numVar = size(lb,2);
    if numVar ~= size(ub,2)
        error([mfilename ':: The lower bounds and upper bounds inputs must match.'])
    end
    switch lower(method)
        
        case 'sobol'
            
            P     = sobolset(numVar);
            X     = net(P,draws);
            lbSim = 0;
            ubSim = 1;
            
        case 'halton'

            P     = haltonset(numVar);
            X     = net(P,draws);
            lbSim = 0;
            ubSim = 1;
            
        case 'latin'
            
            X     = nb_latinHypercubeSim(draws, numVar);
            lbSim = 0;
            ubSim = 1;
            
        otherwise 
            error([mfilename ':: Unsupported method ' method])
    end
    
    X = bsxfun(@minus,X,lbSim);
    X = bsxfun(@times,(ub - lb)/(ubSim - lbSim),X);
    X = bsxfun(@plus,X,lb);
    
end

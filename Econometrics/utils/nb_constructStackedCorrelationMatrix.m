function sigmaF = nb_constructStackedCorrelationMatrix(c)
% Syntax:
%
% sigmaF = nb_constructStackedCorrelationMatrix(c)
%
% Description:
%
% Construct the stacked correlation matrix.
% 
% Input:
% 
% - c : A nVar x nVar x nLags + 1 x nPage double storing the  
%       (auto)correlation matrices. The first page stores the 
%       contemporaneous correlation matrix, second the autocorrelation 
%       matrix with lag 1 and so on.
%       
% Output:
% 
% - sigmaF : The stacked correlation matrix. As a 
%            nVar*(nLags+1) x nVar*(nLags+1) x nPage double.
%
% See also:
% nb_calculateMoments, nb_model_generic.theoreticalMoments
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nDep   = size(c,1);
    nLags  = size(c,3) - 1;
    nPage  = size(c,4);
    nDim   = nDep*(nLags+1);
    sigmaF = zeros(nDim,nDim,nPage);
    I      = eye(nLags+1);
    for pp = 1:nPage
        sigmaT = sigmaF(:,:,pp);
        for ii = 2:nLags+1
            repl   = [zeros(ii-1,nLags-ii+2);I(ii:end,ii:end)];
            repl   = [repl,zeros(nLags+1,ii-1)]; %#ok<AGROW>
            sigmaT = sigmaT + kron(repl,c(:,:,ii,pp));
        end
        sigmaT         = sigmaT + sigmaT';
        sigmaT         = sigmaT + kron(I,c(:,:,1));
        sigmaF(:,:,pp) = sigmaT;
    end
    
end

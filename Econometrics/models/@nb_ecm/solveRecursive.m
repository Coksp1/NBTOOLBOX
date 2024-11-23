function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_ecm.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    iter    = size(results.beta,3);
    tempSol = nb_ecm.solveNormal(results,opt,1);
    A       = tempSol.A(:,:,ones(1,iter));
    B       = tempSol.B(:,:,ones(1,iter));
    C       = tempSol.C(:,:,ones(1,iter));
    for ii = 2:iter
        tempSol   = nb_ecm.solveNormal(results,opt,ii);
        A(:,:,ii) = tempSol.A;
        B(:,:,ii) = tempSol.B;
        C(:,:,ii) = tempSol.C;
    end
    tempSol.A     = A;
    tempSol.B     = B;
    tempSol.C     = C;
    tempSol.class = 'nb_ecm';
    tempSol.type  = 'nb';

end

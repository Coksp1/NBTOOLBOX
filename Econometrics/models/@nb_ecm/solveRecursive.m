function tempSol = solveRecursive(results,opt)
% Syntax:
%
% tempSol = nb_ecm.solveRecursive(results,opt,ident)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    iter     = size(results.beta,3);
    nEndo    = length(opt.endogenous);
    rhs      = opt.rhs((nEndo+1)*2:end); % The flexible right hand side variables
    depLags  = regexp(rhs,opt.dependent);
    endoLags = rhs(cellfun(@isempty,depLags));
    depLags  = rhs(~cellfun(@isempty,depLags));
    nDepLags = regexp(depLags,'\d+$','match');
    nDepLags = str2num(char([nDepLags{:}]')); %#ok<ST2NM>
    mDepLags = max(nDepLags);
    if isempty(mDepLags)
        mDepLags = 1;
    end
    nExo = length(opt.exogenous) + opt.constant + opt.time_trend + length(endoLags) + nEndo*2;
    nEq  = mDepLags + 1;
    A    = nan(nEq,nEq,iter);
    B    = nan(nEq,nExo,iter);
    C    = nan(nEq,1,iter);
    for ii = 1:iter
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

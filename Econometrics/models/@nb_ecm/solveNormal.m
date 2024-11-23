function tempSol = solveNormal(results,opt,iter)
% Syntax:
%
% tempSol = nb_ecm.solveNormal(results,opt,iter)
%
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        iter = 1;
    end

    % Get the estimated equation
    beta    = results.beta(:,:,iter);
    nExo    = length(opt.exogenous) + opt.constant + opt.time_trend;
    nEndo   = length(opt.endogenous);
    betaExo = beta(1:nExo);
    beta    = beta(nExo+1:end);
    if strcmpi(opt.method,'twoStep')
        
        % Note: recursive estimation is not supported when two step
        % appraoch
        
        % Insert the first step into second step to get;
        % diff_dep_t = const + gamma*[dep_t_1;exo_t_1] + kappa0*diff_exo_t + kappa_1*diff_dep_t_1 + kappa_2*diff_exo_t_1 + e
        betaFS  = results.firstStep(1).results.beta;
        constFS = betaFS(1);
        alpha   = beta(1);
        if opt.constant
            betaExo(1) = betaExo(1) + alpha*constFS;
        end
        gamma   = alpha*[1,-betaFS(2:end)'];
        kappa0  = beta(2:nEndo+1)';
        rhs     = opt.rhs(nEndo+2:end); % The flexible right hand side variables
    else   
        % diff_dep_t = const + gamma*[dep_t_1;exo_t_1] + kappa0*diff_exo_t + kappa_1*diff_dep_t_1 + kappa_2*diff_exo_t_1 + e
        gamma         = beta(1:nEndo+1)';
        rhs           = opt.rhs(nEndo+2:end);
        kappa0        = zeros(1,nEndo);
        diffEndoInd   = cellfun(@isempty,regexp(rhs,'_lag\d{1,2}$','start'));
        diffEndo      = rhs(diffEndoInd);
        [~,loce0]     = ismember(diffEndo,strcat('diff_',opt.endogenous));
        betaT         = beta(nEndo+2:end);
        kappa0(loce0) = betaT(diffEndoInd)';
        rhs           = rhs(~diffEndoInd); % The flexible right hand side variables
    end
        
    % Find the flexible variables coeff of the dependent variable
    depLags       = regexp(rhs,opt.dependent);
    endoLags      = rhs(cellfun(@isempty,depLags));
    depLags       = rhs(~cellfun(@isempty,depLags));
    nDepLags      = regexp(depLags,'\d+$','match');
    nDepLags      = str2num(char([nDepLags{:}]')); %#ok<ST2NM>
    mDepLags      = max(nDepLags);
    depAllLags    = nb_cellstrlag(opt.dependent,mDepLags);
    kappa1        = zeros(1,length(depAllLags));
    [indDL,indDB] = ismember(depAllLags,opt.rhs);
    kappa1NZ      = beta(indDB(indDL))';
    kappa1(indDL) = kappa1NZ;
    [~,indEB]     = ismember(endoLags,opt.rhs);
    kappa2        = beta(indEB)';
    
    % Get the matrix on contemporanous variables of the right hand side
    if isempty(mDepLags)
        mDepLags = 1;
        kappa1   = 0;
    end
    A0x   = [zeros(mDepLags,mDepLags+1);1,zeros(1,mDepLags)];
    A0    = eye(mDepLags+1) - A0x;

    % Get the A matrix
    A                          = zeros(mDepLags+1);
    A(1,:)                     = [kappa1,gamma(1)];
    A(2:mDepLags,1:mDepLags-1) = eye(mDepLags-1);
    A(mDepLags+1,mDepLags+1)   = 1;

    % Get B matrix
    betaEndo = [gamma(2:end),kappa0,kappa2];
    B        = [betaExo',betaEndo;zeros(size(A,1)-1,nExo+size(betaEndo,2))];

    % Get C matrix
    C = [1;zeros(mDepLags,1)];

    % Then solve for the endogneous variables
    A = A0\A;
    B = A0\B;
    C = A0\C;

    % Return solution
    tempSol.A   = A;
    tempSol.B   = B;
    tempSol.C   = C;
    tempSol.vcv = results.sigma;
        
    % Get the names
    lhs    = opt.dependent;
    rhs    = opt.rhs;
    endo   = strrep(lhs,'diff_','');
    exo    = opt.exogenous;
    if opt.time_trend
        exo = ['Time-trend',exo]; %#ok<*AGROW>
    end
    if opt.constant
        exo = ['Constant',exo];
    end
    tempSol.endo  = [strcat('diff_',endo),nb_cellstrlag(strcat('diff_',endo),mDepLags-1),endo];
    if strcmpi(opt.method,'twoStep')
        [t,indExoExt] = ismember(betaEndo(nEndo+1:end),beta');
        tempSol.exo   = [exo,strcat(opt.endogenous,'_lag1'),rhs(indExoExt(t))];
    else
        rhs           = opt.rhs(nEndo+2:end);
        rhs           = rhs(~diffEndoInd);
        indExoExt     = ~ismember(rhs,depLags);
        tempSol.exo   = [exo,opt.rhs(2:nEndo+1),strcat('diff_',opt.endogenous),rhs(indExoExt)];
    end
    
    tempSol.res   = strcat('E_diff_',endo);
    tempSol.class = 'nb_ecm';
    tempSol.type  = 'nb';

end

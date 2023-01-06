function S = ABidentification(ident,A,sigma,maxDraws,draws)
% Syntax:
%
% S = nb_var.ABidentification(ident,A,sigma,maxDraws,draws,ask)
%
% Description:
%
% Identification of VAR model using combination of zero and sign
% restrictions. See Binning (2013), "Underidentified SVAR models: A 
% framework for combining short and long-run restrictions with 
% sign-restrictions". Many thanks to him for supplying help!
%
% As a extension to Binning (2013) this code also allow for magnitude 
% restrictions.
% 
% Input:
% 
% - ident    : The identification assumption, as a struct. See 
%              set_identification method of the nb_var class for more
%
% - A        : Transition matrix
%
% - sigma    : Covariance matrix of the VAR residuals.
% 
% - maxDraws : The number of maximal rotations when looking
%              for a identification satifying the sign
%              restrictions. Can be set to inf. Default is
%              10000.
%
% - draws    : The number of wanted draws of the matrix of the
%              map from structural shocks to dependent
%              variables (C). Default is one.
%
% Output:
% 
% - S     : A nb_struct with field W, with the stored map from structural
%           shocks to dependent variables.
%
% Written by Kenneth Sæterhagen Paulsen, 
% Subfunctions of this code are written by Andrew Binning.

% Copyright Andrew Binning 2013
% Please feel free to use and modify this code as you see if fit. If you
% use this code in any academic work, please cite 
% Andrew Binning (2013),
% "Underidentified SVAR models: A framework for combining short and 
% long-run restrictions with sign-restrictions",
% Working Paper 2013/14, Norges Bank.

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(A)
        A = zeros(size(sigma));
    end

    if draws == 1
 
        [W,success,counter] = identify(ident,A,sigma,maxDraws);
        if ~success
            error([mfilename ':: The number of tried rotation (' int2str(maxDraws) ') did not succeed.'])
        else
            S = struct('W',W,'success',success,'counter',counter);
        end
        
    else
        
        % Create waiting bar window
        h      = nb_waitbar([],'Identification',draws,true);
        h.text = 'Starting...'; 
        
        nRes    = size(sigma,1);
        W       = nan(nRes,nRes,1,draws);
        counter = 1;
        ii      = 0;
        kk      = 1;
        while kk <= draws
            
            ii = ii + 1;
            
            [WD,success,count] = identify(ident,A,sigma,maxDraws);
            if success
                
                W(:,:,1,kk) = WD;
                
                % Report current estimate in the waitbar's message field
                if h.canceling
                    error([mfilename ':: User terminated'])
                end
                h.status = kk;
                h.text   = ['Finished with ' int2str(kk) ' replications in ' int2str(ii) ' tries...']; 
                counter  = counter + count;
                kk       = kk + 1;
                
            end
            
        end
        
        S = nb_struct('W',W,'success',0,'counter',counter/draws);
        
        % Delete the waitbar.
        delete(h) 
        
    end

end

%==========================================================================
% SUB
%==========================================================================
function [W,success,counter] = identify(ident,A,sigma,maxDraws)

    C        = chol(sigma,'lower');
    Q        = ident.Q;
    counter  = 0;
    nDep     = size(C,1);
    nLags    = size(A,1)/nDep;
    nRows    = nDep*(nLags-1);
    index    = ident.index;
    SR       = ident.SR;
    SRind    = ident.SRind;
    indInf   = isinf(SRind);
    SRind    = SRind(~indInf);
    MR       = ident.MR;
    MRind    = ident.MRind;
    MRindInf = isinf(MRind);
    MRind    = MRind(~MRindInf);
    MRV      = ident.MRV;
    CR       = ident.CR;
    CRmax    = ident.CRmax;
    success  = 0;
    while ~success && counter < maxDraws
    
        % Generate a draw of map from structural shocks to dependent 
        % variables when the model is underidentified
        if ident.flag == -1 
            C = generateDraw(C,nDep);
        end
        
        % Get the rotation matrix given zero restrictions
        P               = findP(ident,C,A,Q,nLags,nDep,index);
        W               = C*P;
        W(abs(W)<1e-12) = 0;
        
        % Check the sign restrictions
        if isempty(SR)
            innerFailed = false;
        else
            innerFailed = checkSignRestriction(A,W,SR,SRind,indInf,nRows,nDep);
        end
        
        % Check the magnitude restrictions. It will be much more efficient
        % to do sign and magnitude restriction in one go, if both are 
        % given, but I don't want to slow down identification if magnitude
        % restriction are not given.
        if ~isempty(MR) && ~innerFailed
            innerFailedMR = checkMagnitudeRestriction(A,W,MR,MRind,MRindInf,MRV,nRows,nDep);
            innerFailed   = innerFailedMR || innerFailed;
        end
        
        % Check the cumulative restrictions. It will be much more efficient
        % to do sign and cumulative restriction in one go, if both are 
        % given, but I don't want to slow down identification if cumulative
        % restriction are not given.
        if ~nb_isempty(CR) && ~innerFailed
            innerFailedCR = checkCumulativeRestriction(A,W,CR,CRmax,nRows,nDep);
            innerFailed   = innerFailedCR || innerFailed;
        end
        
        success = ~innerFailed;
        counter = counter + 1;

    end

end

%==========================================================================
function innerFailed = checkSignRestriction(A,W,SR,SRind,indInf,nRows,nDep)

    for jj = 1:nDep % For each shock

        % Test sign restriction on impact for each shock
        y0     = zeros(nDep,1);
        y0(jj) = 1;
        CMAP   = [W;zeros(nRows,nDep)];
        y0     = CMAP*y0; % Response on impact
        if ismember(0,SRind)
            indTest     = 1:nDep;
            tested      = ~isnan(SR(indTest,jj));
            yt          = y0(1:nDep);
            irfTest     = sign(yt(tested)) - SR(indTest(tested),jj);
            innerFailed = any(irfTest~=0);
            if innerFailed
                break
            end
        end
       
        % Test sign restriction from period 1 to N for each shock
        for ii = 1:max(SRind)
            y1 = A*y0;
            if ismember(ii,SRind)
                indTest     = 1 + nDep*ii:nDep*(ii+1);
                tested      = ~isnan(SR(indTest,jj));
                yt          = y1(1:nDep);
                irfTest     = sign(yt(tested)) - SR(indTest(tested),jj);
                innerFailed = any(irfTest~=0);
                if innerFailed
                    break
                end
            end
            y0 = y1;
        end

        if innerFailed
            break
        end

        % Test sign restriction on cumulative long-run response for
        % each shock
        if indInf
            yInf        = getLinf(A,W);
            yt          = yInf(1:nDep);
            tested      = ~isnan(SR(end-nDep+1:end,jj));
            irfTest     = sign(yt(tested)) - SR(tested,jj);
            innerFailed = any(irfTest~=0);
            if innerFailed
                break
            end
        end

    end

end

%==========================================================================
function innerFailed = checkMagnitudeRestriction(A,W,MR,MRind,MRindInf,MRV,nRows,nDep)

    for jj = 1:nDep % For each shock

        % Test magnitude restriction on impact for each shock
        y0     = zeros(nDep,1);
        y0(jj) = 1;
        CMAP   = [W;zeros(nRows,nDep)];
        y0     = CMAP*y0; % Response on impact
        if ismember(0,MRind)
            indTest     = 1:nDep;
            tested      = ~isnan(MR(indTest,jj));
            yt          = y0(1:nDep);
            irfTest     = yt(tested) - MRV(indTest(tested),jj);
            indLower    = MR(indTest(tested),jj) == -1;
            innerFailed = any(irfTest(indLower)>=0) || any(irfTest(~indLower)<=0);
            if innerFailed
                break
            end
        end
       
        % Test magnitude restriction from period 1 to N for each shock
        for ii = 1:max(MRind)
            y1 = A*y0;
            if ismember(ii,MRind)
                indTest     = 1 + nDep*ii:nDep*(ii+1);
                tested      = ~isnan(MR(indTest,jj));
                yt          = y1(1:nDep);
                irfTest     = yt(tested) - MRV(indTest(tested),jj);
                indLower    = MR(indTest(tested),jj) == -1;
                innerFailed = any(irfTest(indLower)>=0) || any(irfTest(~indLower)<=0);
                if innerFailed
                    break
                end
            end
            y0 = y1;
        end

        if innerFailed
            break
        end

        % Test magnitude restriction on cumulative long-run response for
        % each shock
        if MRindInf
            yInf        = getLinf(A,W);
            yt          = yInf(1:nDep);
            tested      = ~isnan(MR(end-nDep+1:end,jj));
            irfTest     = yt(tested) - MRV(indTest(tested),jj);
            indLower    = MR(indTest(tested),jj) == -1;
            innerFailed = any(irfTest(indLower)>=0) || any(irfTest(~indLower)<=0);
            if innerFailed
                break
            end
        end

    end

end

%==========================================================================
function innerFailed = checkCumulativeRestriction(A,W,CR,CRmax,nRows,nDep)

    for jj = 1:nDep % For each shock

        CRshock = CR{jj};
        if isempty(CRshock)
            continue
        end
        
        % Get IRF
        CMAP   = [W;zeros(nRows,nDep)];
        y0     = zeros(nDep,1);
        y0(jj) = 1;
        Y      = nan(nRows + nDep,CRmax{jj}+1);
        Y(:,1) = CMAP*y0; % Response on impact
        for tt = 1:CRmax{jj}
            Y(:,tt+1) = A*Y(:,tt);
        end
        Y = Y(1:nDep,:);
        
        % Test restrictions
        for ii = 1:length(CRshock)
            tested = sum(Y(CRshock(ii).indDep,CRshock(ii).periods+1),2); % Get cumulative response on the restricted variable
            typeS  = CRshock(ii).type;
            if strcmpi(typeS,'cum<')
                innerFailed = tested < CRshock(ii).value;
            else 
                innerFailed = tested > CRshock(ii).value;
            end
            if innerFailed
                break
            end 
        end
        
        if innerFailed
            break
        end
        
    end

end

function P = findP(ident,C,A,Q,p,k,index)
%==========================================================================
% finds the rotation matrix that satisfies the short and long run
% restrictions.  Based on Rubio-Ramirez, Waggoner and Zha 2010.
%
% inputs:
% C = initial short run impact matrix, usually from a cholesky
% decomposition of the forecast error variance
% A = Matrix of coefficients
% Q = A cell containing the linear restrictions for each columnn
% p = number of lags
% k = number of dependent variables
% index = original column ordering in the matrix of restrictions
%
% outputs:
% P = orthogonal rotation matrix 
%
% Copyright Andrew Binning 2013
% Edited by Kenneth S. Paulsen
%==========================================================================
    
    if isempty(ident.Zind) 
        P = eye(k);
%     elseif ident.flag == 0 && all(ident.Zind==0) 
%         P = eye(k); % This is a problem!
    else

        % Get the IRFs of the zero restrictions
        nDep   = size(C,1);
        Zind   = ident.Zind; % Storing the the zero restricted periods
        nHor   = length(Zind);
        Fzero  = nan(nDep*nHor,nDep);
        indImp = Zind==0;
        jj     = 0;
        if any(indImp)
            Fzero(1:nDep,:) = C;
            jj              = 1;
        end
        Zind   = Zind(~indImp);
        indInf = Zind == inf;
        Zind   = Zind(~indInf);
        y0     = [C;zeros(k*(p-1),k)];
        
        for ii = 1:max(Zind)
            y1 = A*y0;
            if ismember(ii,Zind)
                Li           = y1(1:k,:);
                ind          = nDep*jj+1:nDep*(jj+1);
                Fzero(ind,:) = Li;
                jj           = jj + 1;
            end  
            y0 = y1;
        end
        
        if any(indInf)
            
            Linf         = getLinf(A,C);
            ind          = nDep*jj+1:nDep*(jj+1);
            Fzero(ind,:) = Linf;
            
        end
        
        % Get the rotation matrix
        P = zeros(k,k);
        for ii = 1:k

            if ii == 1
                Qtilde = Q{ii}*Fzero;
            else
                Qtilde = [Q{ii}*Fzero;P'];
            end
            [QQ,~]  = qr(Qtilde');
            P_temp  = QQ(:,end);
            P(:,ii) = P_temp;

        end

        P = P(:,index);
        
    end

end

function Linf = getLinf(A,C)

    k      = size(C,1);
    p      = size(A,1)/k;
    A_temp = A(1:k,:);
    B      = zeros(k,k);
    for ii = 1:p
        ind = (1:k)+(ii-1)*k;
        B   = B + A_temp(:,ind);
    end
    Linf = (eye(k) - B)\C;
    
end

function C = generateDraw(C,k)
%==========================================================================
% Generates a draw that is consistent with the shock variance/covariance
% matrix. Based on Rubio-Ramirez, Waggoner and Zha 2010.
%
% inputs:
% C = initial impact matrix, usually from the cholesky decomposition of the
% forecast error variance decomposition
% k = number of dependent variables
% 
% outputs:
% C = new draw of the short run impact matrix
%
% Copyright Andrew Binning 2013
%==========================================================================

    newmatrix = randn(k,k);
    [Q,R]     = qr(newmatrix);
    for ii = 1:k
        if R(ii,ii)<0
            Q(:,ii) = -Q(:,ii);
        end
    end
    C = C*Q;

end

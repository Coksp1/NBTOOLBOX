function artificial = nb_blockBootstrap(y,draws,method,blockLength)
% Syntax:
%
% artificial = nb_blockBootstrap(y,draws,method,blockLength)
%
% Description:
%
% Block bootstrap time-series to generate artificial draws from
% the assumed data generating processes.
%
% The time-series are assumed stationary.
% 
% Input:
% 
% - y      : A nobs x nvar x npage double.
%
% - draws  : Number of draws to be made.
%
% - method : The method to use. Either:
%
%            > 'overlapping'    : Overlapping block bootstrap
%
%            > 'nonoverlapping' : Non-overlapping block bootstrap
%
%            > 'random'         : Random length overlapping block
%                                 bootstrap. Can in some cases avoid
%                                 the bootstrapped sample to be
%                                 non-stationary.
%
%           > 'wildrandom'      : Random length wild overlapping block
%                                 bootstrap. Can in some cases avoid
%                                 the bootstrapped sample to be
%                                 non-stationary. 
%
% - blockLength : Length of each blocks. Only for the method 'overlapping'
%                 and 'nonoverlapping'. Default is nobs^(1/3).
% 
% Output:
% 
% - artificial : A nobs x nvar x npage x draws double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        blockLength = [];
        if nargin < 3
            method = 'overlapping';
            if nargin < 2
                draws = 1000;
            end
        end
    end
    
    [T,nvar,npage] = size(y);
    
    switch lower(method)
        
        case 'overlapping'
            
            % Block length
            if isempty(blockLength)
                l = ceil(T^(1/3));
            else
                l = ceil(blockLength);
            end
            num    = T - l;
            blocks = nan(l,nvar,npage,num);
            
            % Block the sample
            for ii = 1:num 
                blocks(:,:,:,ii) = y(ii:ii + l - 1,:,:);
            end
            
            % Randomly generate artifical data
            genNum     = ceil(T/l);
            genLength  = genNum*l;
            blockDraws = ceil(num.*rand(draws,genNum));
            artificial = blocks(:,:,:,blockDraws);
            artificial = reshape(artificial,[genLength,nvar,npage,draws]);
            artificial = artificial(1:T,:,:,:);
            
        case 'nonoverlapping'
            
            % Block length
            if isempty(blockLength)
                l = ceil(T^(1/3));
            else
                l = ceil(blockLength);
            end
            num    = floor(T/l);
            blocks = nan(l,nvar,npage,num);
            
            % Block the sample
            kk = 1;
            for ii = 1:num 
                blocks(:,:,:,ii) = y(kk:kk + l - 1,:,:);
                kk = kk + l;
            end
            
            % Randomly generate artifical data
            genNum     = ceil(T/l);
            genLength  = genNum*l;
            blockDraws = ceil(l.*rand(draws,genNum));
            artificial = blocks(:,:,:,blockDraws);
            artificial = reshape(artificial,[genLength,nvar,npage,draws]);
            artificial = artificial(1:T,:,:,:);
            
        case 'random'
            
            % Block lengths
            ml = T^(1/3);
            TT = ceil((T*1.5)/ml);
            l  = ceil((ml*2)*rand(TT,draws)); % Be sure to draw enough
            
            % Randomly generate artifical data
            artificial  = nan(T,nvar,npage,draws);
            blockDraws  = ceil(T.*rand(TT,draws)); % Be sure to draw enough starting points 
            for ii = 1:draws
                
                kk = 1;
                aa = 1;
                while aa - 1 ~= T

                    % Get the block with random length
                    start   = blockDraws(kk,ii);
                    len     = l(kk,ii);
                    finish  = start + len;
                    try
                        block = y(start:finish,:,:);
                    catch %#ok<CTCH>
                        kk = kk + 1; % Outside bounds
                        continue
                    end
                    
                    % Assign block to output
                    if aa + len > T
                        len = T - aa;
                        artificial(aa:aa + len,:,:,ii) = block(1:len + 1,:,:);
                    else
                        artificial(aa:aa + len,:,:,ii) = block;
                    end
                    kk = kk + 1;
                    aa = aa + len + 1;
                    
                end
                
            end

        case 'wildrandom'
            
            % Block lengths
            ml = T^(1/3);
            TT = ceil((T*1.5)/ml);
            l  = ceil((ml*2)*rand(TT,draws)); % Be sure to draw enough
            
            % Wild part of the bootstrap using the Rademacher distribution
            U       = rand(TT,nvar,1,draws);
            ind     = U <= 0.5;
            U(ind)  = -1;
            U(~ind) = 1;
            U       = U(:,:,ones(1,npage),:);
            
            % Randomly generate artifical data
            artificial  = nan(T,nvar,npage,draws);
            blockDraws  = ceil(T.*rand(TT,draws)); % Be sure to draw enough starting points 
            for ii = 1:draws
                
                kk = 1;
                aa = 1;
                while aa - 1 ~= T

                    % Get the block with random length
                    start   = blockDraws(kk,ii);
                    len     = l(kk,ii);
                    finish  = start + len;
                    try
                        block = y(start:finish,:,:);
                    catch %#ok<CTCH>
                        kk = kk + 1; % Outside bounds
                        continue
                    end
                    
                    % Multiply by a zero random variable (Wild part)
                    Ublock = U(kk,:,:,ii);
                    UBlock = Ublock(ones(1,len+1),:,:);
                    block  = block.*UBlock;
                    
                    % Assign block to output
                    if aa + len > T
                        len = T - aa;
                        artificial(aa:aa + len,:,:,ii) = block(1:len + 1,:,:);
                    else
                        artificial(aa:aa + len,:,:,ii) = block;
                    end
                    kk = kk + 1;
                    aa = aa + len + 1;
                    
                end
                
            end    
            
        otherwise
            
            error([mfilename ':: Unsupprted block bootstrap method ' method])
            
    end

end

%==========================================================================
% SUB
%==========================================================================
function Bstar = optBlockLength(data)
% function Bstar = optBlockLength(data);
%
% This is a function to select the optimal (in the sense
% of minimising the MSE of the estimator of the long-run
% variance) block length for the stationary bootstrap or circular bootstrap.
% Code follows Politis and White, 2001, "Automatic Block-Length
% Selection for the Dependent Bootstrap".
%
%  DECEMBER 2007: CORRECTED TO DEAL WITH ERROR IN LAHIRI'S PAPER, PUBLISHED
%  BY NORDMAN IN THE ANNALS OF STATISTICS
%
%  NOTE:    The optimal average block length for the stationary bootstrap, 
%           and it does not need to be an integer. The optimal block length 
%           for the circular bootstrap should be an integer. Politis and 
%           White suggest rounding the output UP to the nearest integer.
%
% INPUTS:	data, an nxk matrix
%
% OUTPUTS:	Bstar, a 2xk vector of optimal bootstrap block lengths, 
%           [BstarSB;BstarCB]
%
%  Andrew Patton
%
%  4 December, 2002
% 	Revised (to include CB): 13 January, 2003.
%
% Helpful suggestions for this code were received from Dimitris Politis and 
% Kevin Sheppard.
%
% Modified 23.8.2003 by Kevin Sheppard for speed issues
% Modified 10.12.2015 by Kenneth S. Paulsen for speed issues

    [n,k] = size(data);

    % these are optional in opt_block_length_full.m, but fixed at default values here
    KN          = max(5,sqrt(log10(n)));
    mmax        = ceil(sqrt(n))+KN;           % adding KN extra lags to employ Politis' (2002) suggestion for finding largest signif m
    Bmax        = ceil(min(3*sqrt(n),n/3));  % dec07: new idea for rule-of-thumb to put upper bound on estimated optimal block length
    c           = 2;
    origdata    = data;
    Bstar_final = nan(2,k);
    Bstar       = nan(2,1);
    
    for i=1:k

       data=origdata(:,i);

       % FIRST STEP: finding mhat-> the largest lag for which the autocorrelation is still significant.
       temp = nb_mlag(data,mmax,'varFast');
       temp = temp(mmax+1:end,:);	% dropping the first mmax rows, as they're filled with zeros
       temp = corrcoef([data(mmax+1:end),temp]);
       temp = temp(2:end,1);

       % We follow the empirical rule suggested in Politis, 2002, "Adaptive Bandwidth Choice".
       % as suggested in Remark 2.3, setting c=2, KN=5
       temp2 = [nb_mlag(temp,KN,'varFast')',temp(end-KN+1:end)];		% looking at vectors of autocorrels, from lag mhat to lag mhat+KN
       temp2 = temp2(:,KN+1:end);		% dropping the first KN-1, as the vectors have empty cells
       temp2 = (abs(temp2)<(c*sqrt(log10(n)/n)*ones(KN,mmax-KN+1)));	% checking which are less than the critical value
       temp2 = sum(temp2)';		% this counts the number of insignif autocorrels
       temp3 = [(1:1:length(temp2))',temp2];
       temp3 = temp3(temp2==KN,:);	% selecting all rows where ALL KN autocorrels are not signif
       if isempty(temp3)
          mhat = max(find(abs(temp) > (c*sqrt(log10(n)/n)) )); %#ok<MXFND> % this means that NO collection of KN autocorrels were all insignif, so pick largest significant lag
       else
          mhat = temp3(1,1);	% if more than one collection is possible, choose the smallest m
       end
       if 2*mhat>mmax;
          M = mmax;
       else
          M = 2*mhat;
       end
       clear temp temp2 temp3;

       % SECOND STEP: computing the inputs to the function for Bstar
       kk = (-M:1:M)';

       if M>0;
           
          temp = nb_mlag(data,M,'varFast');
          temp = temp(M+1:end,:);	% dropping the first mmax rows, as they're filled with zeros
          temp = cov([data(M+1:end),temp]);
          acv  = temp(:,1);			% autocovariances
          acv2 = [-(1:1:M)',acv(2:end)];
          if size(acv2,1)>1;
             acv2 = sortrows(acv2,1);
          end
          acv    = [acv2(:,2);acv];	%#ok<AGROW> % autocovariances from -M to M
          Ghat   = sum(lam(kk/M).*abs(kk).*acv);
          DCBhat = 4/3*sum(lam(kk/M).*acv)^2;
          clear acv2;
          
          % NEW dec07
          DSBhat = 2*(sum(lam(kk/M).*acv)^2);	% first part of DSBhat (note cos(0)=1)

          % FINAL STEP: constructing the optimal block length estimator
          Bstar(1) = ((2*(Ghat^2)/DSBhat)^(1/3))*(n^(1/3));
          if Bstar(1) > Bmax
             Bstar(1) = Bmax;
          end
          BstarCB = ((2*(Ghat^2)/DCBhat)^(1/3))*(n^(1/3));

          if BstarCB > Bmax
             BstarCB = Bmax;
          end      
          Bstar(2) = [Bstar;BstarCB];
       else
          Ghat = 0; %#ok<NASGU>
          % FINAL STEP: constructing the optimal block length estimator
          Bstar = [1;1];
       end
       Bstar_final(:,i) = Bstar;
       
    end

    Bstar = Bstar_final;

end

%==========================================================================
function lam=lam(kk)
    %Helper function, calculates the flattop kernel weights
    lam = (abs(kk)>=0).*(abs(kk)<0.5)+2*(1-abs(kk)).*(abs(kk)>=0.5).*(abs(kk)<=1);
end

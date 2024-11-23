function vcv = estimateCovarianceMatrixDuringRecEst(options,residual,...
    indCovid,start,T,ss,numCoeff)
% Syntax:
%
% vcv = nb_estimator.estimateCovarianceMatrixDuringRecEst(options,...
%           residual,indCovid,start,T,ss,numCoeff)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    kk     = 1;
    numDep = size(residual,2);
    iter   = size(residual,3);
    numQ   = size(residual,4);
    vcv    = nan(numDep,numDep,iter,numQ);
    if numQ > 1

        for qq = 1:numQ
            kk = 1;
            for tt = start:T
                resid = residual(ss(kk):tt-options.nStep,:,kk,qq);
                if ~isempty(indCovid)
                    % Remove covid observations from time-series of
                    % residuals, as these have been predicted using
                    % estimated beta before ending up here...
                    if options.nStep
                        indCovidTT = nb_estimator.getSteapAheadIndCovidAll(options.nStep,indCovid(ss(kk):tt,:));
                        indCovidTT = indCovidTT(1:end-options.nStep);
                    else
                        indCovidTT = indCovid(ss(kk):tt,:);
                    end
                    resid(~indCovidTT,:) = [];
                end
                residClean     = bsxfun(@minus,resid,mean(resid,1));
                vcv(:,:,kk,qq) = residClean'*residClean/(size(residClean,1) - numCoeff);
                kk             = kk + 1;
            end
        end

    else

        for tt = start:T
            resid = residual(ss(kk):tt-options.nStep,:,kk);
            if ~isempty(indCovid)
                % See comment above!
                if options.nStep
                    indCovidTT = nb_estimator.getSteapAheadIndCovidAll(options.nStep,indCovid(ss(kk):tt,:));
                    indCovidTT = indCovidTT(1:end-options.nStep);
                else
                    indCovidTT = indCovid(ss(kk):tt,:);
                end
                resid(~indCovidTT,:) = [];
            end
            vcv(:,:,kk) = resid'*resid/(size(resid,1) - numCoeff);
            kk          = kk + 1;
        end

    end

end

function resAll = predictResidual(yCov,XCov,constant,time_trend,beta,res,indCovid)
% Syntax:
%
% resAll = nb_estimator.predictResidual(yCov,XCov,constant,time_trend,...
%               beta,res,indCovid)
%
% Description:
%
% Predict residuals for periods ignored by the covidAdj input.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if time_trend
        tt = 1:size(indCovid,1);
        tt = tt(~indCovid);
        XCov  = [tt',XCov];
    end
    if constant
        XCov = [ones(size(XCov,1),1),XCov];
    end

    resAll = nan(size(indCovid,1),size(yCov,2),size(beta,3));
    if size(beta,3) > 1 % Quantile estimator
        for qq = 1:size(beta,3)
            resAll(~indCovid,:,qq) = yCov - XCov*beta(:,:,qq);
        end
    else
        resAll(~indCovid,:) = yCov - XCov*beta;
    end
    resAll(indCovid,:,:) = res;

end

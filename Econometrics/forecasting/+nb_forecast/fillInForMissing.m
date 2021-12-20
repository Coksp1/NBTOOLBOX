function mv = fillInForMissing(DYbar,myv,nVarY,nCondPer,mev,nVarE,nCondPerE)
% Syntax:
%
% MUc = nb_forecast.fillInForMissing(DYbar,myv,nVarY,nCondPer,...
%                   mev,nVarE,nCondPerE)
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Replace the conditional mean by its theoretical counterpart for the
    % conditioning variables that do not have a mean at all conditioning
    % horizons. If there is at least one non-nan element, the conditional 
    % mean is unchanged
    ncvcp = nVarY*nCondPer;
    if ~any(any(isfinite([LBy,UBy]))) && ~isempty(LBy) % Only if truncated dist is used
        myv = replaceFullVectorIfMissing(myv,DYbar(1:ncvcp),nVarY,nCondPer);
    end
    if ~any(any(isfinite([LBs,UBs]))) && ~isempty(LBs) % Only if truncated dist is used
        mev = replaceFullVectorIfMissing(mev,DYbar(ncvcp+1:end),nVarE,nCondPerE);
    end
    mv = [myv;mev];
    LB  = [LBy;LBs];
    UB  = [UBy;UBs];

end

%==========================================================================
function MU = replaceFullVectorIfMissing(MU,TheoMean,ncv,ncp)
    
    if ~isequal(size(MU),size(TheoMean))
        error([mfilename,':: conditional and theoretical mean should have the same length'])
    end
    
    index=(0:ncp-1)*ncv;
    for j=1:ncv
        if all(isnan(MU(index+j))) % then we assume the mean is not distorted
            MU(index+j)=TheoMean(index+j);
        end
    end
    
end

function [ci,limInd] = nb_hdi(data,limits,dim,varargin)
% Syntax:
%
% ci = nb_hdi(data)
% ci = nb_hdi(data,limits,dim,varargin)
%
% Description:
%
% Construct credibility interval by the highest density interval method
% 
% Input:
% 
% - data   : A dim1 x dim2 x dim3 double. Can include nan values
%
% - limits : The wanted limits, as a 1 x nLim. E.g:
% 
%            - 0.9       : Gives the 90 percent highest density interval. 
%                          (Default)
%
%            - [0.1,0.2] : Gives the 10 and 20 percent highest density
%                          intervals.
% 
% - dim   : The dimension to calculate the highest density interval over.
%           Default is 1.
%
% Optional inputs:
%
% - varargin : Optional input given to the nb_ksdensity function.
%
% Output:
% 
% - ci     : A double where the dimension given by dim has been changed to
%            match the number of found intervals (these may be more than 
%            nLim*2, as this measure over intervals may be 
%            non-overlapping).
%
% - limInd : A double matching the return number of intervals. If 
%            ci is a dim1 x dim2 x rLim, then this output is 1 x 1 x rLim
%            cellstr.
%
% Examples:
%
% [ci,limInd] = nb_hdi(randn(100,1),[0.1,0.2],1) 
%
% See also:
% nb_ksdensity
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dim = 1;
        if nargin < 2
            limits = 0.9;
        end
    end
    limits = limits*100;

    switch dim
        case 1
            % Do nothing
        case 2
            data = permute(data,[2,1,3]);
        case 3
            data = permute(data,[3,2,1]);
        otherwise
            error([mfilename ':: Cannot calculate highest density intervals in the dimension '  int2str(dim)])
    end
    
    % Get the (potential) limits
    [~,s2,s3] = size(data);
    if ~isrow(limits)
        error([mfilename ':: The limits input must be a row vector.'])
    end
    nLim   = size(limits,2)*6;
    limInd = cell(nLim,1);
    lims   = strtrim(cellstr(num2str(limits')))';
    app    = {'lb1_','ub1_','lb2_','ub2_','lb3_','ub3_'};
    for ii = 1:size(limits,2)
        ind         = 1+(ii-1)*6:ii*6;
        limInd(ind) = strcat(app,lims{ii});
    end

    % Calculate the intervals
    ci = nan(nLim,s2,s3); 
    for ii = 1:s2
        for jj = 1:s3
            ci(:,ii,jj) = calc_hdi(data(:,ii,jj),limits,varargin);
        end
    end
    
    ind    = ~all(all(isnan(ci),2),3);
    ci     = ci(ind,:,:); 
    limInd = limInd(ind);
    
    switch dim
        case 1
            % Do nothing
        case 2
            ci     = permute(ci,[2,1,3]);
            limInd = permute(limInd,[2,1,3]);
        case 3
            ci     = permute(ci,[3,2,1]);
            limInd = permute(limInd,[3,2,1]);
    end
    
end

%==========================================================================
function ci = calc_hdi(x,limits,inputs)

    nLim     = size(limits,2);
    nLimAll  = nLim*6;
    ci       = nan(nLimAll,1);

    % Do kernel density estimation  
    try
        xi = nb_distribution.estimateDomain(x);
        f  = nb_ksdensity(x',xi',inputs{:});
    catch
        ci(:) = x(1); 
        return
    end
    f = f(:);
    
    % Check that the density sums to 1
    binsL   = xi(2) - xi(1);
    testCDF = cumsum(f)*binsL; 
    topCDF  = max(testCDF);
    if topCDF < sqrt(eps)
        % The variable are constant across draws
        ci(:) = x(1); 
        return
    elseif topCDF > nb_kernelCDFBounds(0) || topCDF < nb_kernelCDFBounds(1)
        
        % Try wider domain
        try
            xi = nb_distribution.estimateDomain(x,2);
            f  = nb_ksdensity(x',xi',inputs{:});
        catch
            ci(:) = x(1); 
            return
        end
        f = f(:);

        % Check that the density sums to 1
        binsL   = xi(2) - xi(1);
        testCDF = cumsum(f)*binsL; 
        topCDF  = max(testCDF);
        if topCDF > nb_kernelCDFBounds(0) || topCDF < nb_kernelCDFBounds(1)
            error([mfilename ':: A CDF return by the ksdensity function did not sum to 1, which is not possible by definition of a density. '...
                             'Is (' num2str(topCDF) '). This is probably due to a mispecified domain.']);
        end
        
    end
    
    % Estimate the highest density intervals
    [fs,ind] = sort(f,1,'descend');
    fs       = cumsum(fs)*binsL;
    for ii = 1:nLim
        cit      = calc_hdi_one(fs,xi,ind,limits(ii));
        indC     = 1+(ii-1)*6:ii*6;
        ci(indC) = cit;
    end
    
end

%==========================================================================
function cit = calc_hdi_one(fs,xi,order,limit)

    % Find treshold
    ind  = fs <= limit/100;
    if ~any(ind)
        ind  = [true;ind(2:end)];
    end
    
    % Group
    ord    = order(ind);
    ords   = sort(ord);
    groups = cell(1,3); 
    gg     = 1;
    kk     = 1;
    for ii = 2:size(ords)
        if ords(ii) - ords(ii-1) ~= 1
            if gg > 2
                error([mfilename ':: Cannot handle more than trimodal distributions.'])
            end
            groups{gg} = ords(kk:ii-1);
            gg = gg + 1;
            kk = ii;
        end
    end
    if isempty(ii)
        ii = 1;
    end
    groups{gg} = ords(kk:ii);
    
    % Find limits of each group
    cit = nan(6,1); 
    for gg = 1:3 
        groupInd = groups{gg};
        if ~isempty(groupInd)
            xit         = xi(groupInd);
            cit(gg*2-1) = min(xit);
            cit(gg*2)   = max(xit);
        end
    end

end

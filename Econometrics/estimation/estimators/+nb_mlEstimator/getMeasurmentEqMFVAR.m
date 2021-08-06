function [H,freqD,extraAdded] = getMeasurmentEqMFVAR(options,extra)
% Syntax:
%
% [H,freqD,extraAdded] = nb_mlEstimator.getMeasurmentEqMFVAR(options,extra)
%
% Description:
%
% Get measurment equation of a mixed frequency VAR.
% 
% See also:
% nb_mlEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        extra = 0;
    end
    
    % Fill in default values
    [~,dataFreq]  = nb_date.date2freq(options.dataStartDate);
    freq          = options.frequency(~options.indObservedOnly);
    nFreq         = size(freq,2);
    indF          = cellfun(@isempty,freq);
    freq(indF)    = {dataFreq};
    freqDAfter    = nan(1,nFreq);
    freqD         = nan(1,nFreq);
    periods       = nan(1,nFreq);
    for ii = 1:nFreq
       if iscell(freq{ii})
           
           freqD(ii)      = freq{ii}{1};
           periods(ii)    = freq{ii}{2};
           freqDAfter(ii) = freq{ii}{3};
           if periods(ii) < options.estim_start_ind
               % Change in the frequency changes before the estimation
               % period starts
               periods(ii)    = nan;
               freqD(ii)      = freqDAfter(ii);
               freqDAfter(ii) = nan;
           elseif periods(ii) > options.estim_end_ind
               % Change in the frequency changes after the estimation
               % period ends
               periods(ii)    = nan;
               freqDAfter(ii) = nan;
           end
           
       else
           freqD(ii) = freq{ii};
       end
    end
    indOtherFreq  = freqD ~= dataFreq;
    mapping       = options.mapping(~options.indObservedOnly);
    mapping       = mapping(indOtherFreq);
    indM          = cellfun(@isempty,mapping);
    mapping(indM) = {'diffAverage'};

    % Initialize the map from state to measured variables
    type = 1;
    if any(ismember({'diffSummed','diffAverage'},mapping))
        type = 2;
    elseif any(ismember({'levelSummed','levelAverage'},mapping))
        type = 3;
    end
    maxFreq = max(freqD);
    minFreq = min(freqD);
    
    if maxFreq > 52
        error([mfilename ':: Cannot handle mixed frequency model with daily data.'])
    end
    
    % Do we change the frequency for any variables?
    if any(~isnan(freqDAfter))
        [H,extraAdded] = freqChangedH(options,periods,freqD,freqDAfter,maxFreq,type,mapping,indOtherFreq,extra); 
    else
        [H,extraAdded] = doOnePeriod(options,freqD,maxFreq,minFreq,type,mapping,indOtherFreq,extra);
    end
    
    % Do we observe any variable with more than one frequency
    if any(options.indObservedOnly)
        [H,extraAdded] = doMixing(options,H,extraAdded,maxFreq,type,extra);
    end
    
end

%==========================================================================
function [HH,extraAdded] = freqChangedH(options,periods,freqD,freqDAfter,maxFreq,type,mapping,indOtherFreq,extra)
% Correct the measurement equations due to change in frequency of some 
% variables. I.e. split the sample into sub-periods with stable frequency
% mapping (but still time-varying if we are dealing with weekly data)

    % Get the frequencies of the variables for each sub-period
    periodsU  = unique(periods);
    periodsUS = periodsU(~isnan(periodsU));
    nBreaks   = length(periodsUS);
    freqD     = freqD(ones(1,nBreaks + 1),:);
    for ii = 1:nBreaks
        ind             = periods == periodsUS(ii);
        freqD(ii+1,ind) = freqDAfter(ind);
    end
    start     = [options.estim_start_ind, periodsUS + 1];
    periodsUS = [periodsUS, options.estim_end_ind];
    nPer      = periodsUS - start + 1;
    
    % Get the measurment equation for each sub-period
    H     = cell(nBreaks+1,1);
    opt   = options;
    for ii = 1:nBreaks+1
        opt.estim_start_ind = start(ii);
        opt.estim_end_ind   = periodsUS(ii);
        [H{ii},extraAdded]  = doOnePeriod(opt,freqD(ii,:),maxFreq,min(freqD(ii,:)),type,mapping,indOtherFreq,extra);
        if size(H{ii},3) == 1
            subPeriodLen = periodsUS(ii) - start(ii) + 1;
            H{ii}        = H{ii}(:,:,ones(1,subPeriodLen));
        end
    end
    
    % Expand each measurement equation with equal number of states
    nDep       = size(H{1},1);
    nStates    = cellfun(@(x)size(x,2),H);
    nStatesMax = max(nStates);
    nPerTot    = sum(nPer);
    HH         = zeros(nDep,nStatesMax,nPerTot);
    for ii = 1:size(H,1)
       pers                     = start(ii)-start(1)+1:periodsUS(ii)-start(1)+1;
       HH(:,1:nStates(ii),pers) = H{ii};
    end
    
end

%==========================================================================
function [H,extraAdded] = doOnePeriod(options,freqD,maxFreq,minFreq,type,mapping,indOtherFreq,extra)
% Get the measurement equations of one sub-period. The sample may be split
% into sub-periods due to changes in the frequency of some variables.

    if maxFreq == 52
        
        % In this case we get a time-varying measurment equation
        [H,divFreq,divFreqVar] = getDivFreqWeekly(freqD);
        for ii = 1:length(H)
            [H{ii},extraAdded] = getOneMeasurementEquation(options,maxFreq,divFreq(ii,end),type,mapping,freqD,indOtherFreq,extra,divFreqVar(ii,:));
        end
        
        % Get measurment equation at each period in time
        H = expandH(options,H,divFreq);
        
    else
        [H,extraAdded] = getOneMeasurementEquation(options,maxFreq,maxFreq/minFreq,type,mapping,freqD,indOtherFreq,extra);
    end

end

%==========================================================================
function [H,divFreq,divFreqVar] = getDivFreqWeekly(freqD)
% Get the frequency divsion factors used to find the mappings from high
% to low frequency variables

    freqU = unique(freqD);
    if length(freqU) == 2
        
        switch min(freqD)
            case 12
                H          = cell(1,2);
                divFreqVar = ones(2,size(freqD,2));
                divFreq    = [4;5];
            case 4
                H          = cell(1,3);
                divFreqVar = ones(3,size(freqD,2));
                divFreq    = [12;13;14];
        end
        
        for ii = 1:length(freqD)
            switch freqD(ii)
                case 12
                    divFreqVar(:,ii) = [4;5];
                case 4                 
                    divFreqVar(:,ii) = [12,13,14];
                case 52
                    % Do nothing
                otherwise
                    error([mfilename ':: Cannot combine ' nb_date.getFrequencyAsString(freqD(ii)) ' and weekly frequencies in a MF-VAR.'])
            end
        end

    else % 3 unique frequencies
        
        H          = cell(1,6);
        divFreqVar = ones(6,size(freqD,2));
        for ii = 1:length(freqD)
            switch freqD(ii)
                case 12
                    divFreqVar(:,ii) = [4;4;4;5;5;5];
                case 4
                    divFreqVar(:,ii) = [12;13;14;12;13;14];
                case 52
                    % Do nothing    
                otherwise 
                    error([mfilename ':: Cannot combine ' nb_date.getFrequencyAsString(freqD(ii)) ' and weekly frequencies in a MF-VAR.'])
            end
        end
        
        divFreq = [4,12;
                   4,13;
                   4,14;
                   5,12;
                   5,13;
                   5,14];
        
    end
        
end

%==========================================================================
function [H,extraAdded] = getOneMeasurementEquation(options,maxFreq,divFreq,type,mapping,freqD,indOtherFreq,extra,divFreqVar)
% Get one unique measurment equation

    nDep = length([options.dependent,options.block_exogenous]);
    nDep = nDep - sum(options.indObservedOnly);
    if type == 2 
        dim2       = (divFreq*2 - 1)*nDep;
        extraAdded = false;
    elseif type == 3
        dim2       = divFreq*nDep;
        extraAdded = false;
    else
        dim2       = (options.nLags + extra)*nDep;
        extraAdded = true;
    end
    dim2             = max(dim2,options.nLags*nDep);
    H                = zeros(nDep,dim2);
    H(1:nDep,1:nDep) = eye(nDep);

    % Fill in for the mapping of the variables with lower frequency
    locOtherFreq = find(indOtherFreq);
    freqDI       = freqD(indOtherFreq);
    if nargin == 9
        divFreqVar = divFreqVar(indOtherFreq);
    end
    for ii = 1:length(freqDI)

        loc = locOtherFreq(ii);
        if nargin == 9
            divFreq = divFreqVar(ii);
        else
            divFreq = maxFreq/freqDI(ii);
        end
        switch lower(mapping{ii})
            case 'levelsummed'
                Hi = ones(1,divFreq);
                Li = divFreq;
            case 'diffsummed'
                Hi1 = 1:divFreq;
                Hi2 = divFreq-1:-1:1;
                Hi  = [Hi1,Hi2]; 
                Li  = (divFreq*2 - 1);
            case 'levelaverage'
                Hi = ones(1,divFreq)/divFreq;
                Li = divFreq;
            case 'diffaverage'
                Hi1 = 1:divFreq;
                Hi2 = divFreq-1:-1:1;
                Hi  = [Hi1,Hi2]/divFreq; 
                Li  = (divFreq*2 - 1);
            case 'end'
                Hi = 1;
                Li = 1;    
        end
        Li = Li*nDep;
        H(loc,loc:nDep:Li) = Hi;

    end

end

%==========================================================================
function HH = expandH(options,H,divFreq)
% Get measurment equation at each period in time from all the unique
% possible measurement equations already calculated.

    if size(H,2) <= 3
        
        if divFreq(1) == 4
            method = @(x)getMonth(x);
        else
            method = @(x)getQuarter(x);
        end
        
        periods          = options.estim_end_ind - options.estim_start_ind + 1;
        startW           = nb_date.toDate(options.dataStartDate,52) + (options.estim_start_ind - 1);
        startW.dayOfWeek = options.dayOfWeek;
        endW             = nb_date.toDate(options.dataStartDate,52) + (options.estim_end_ind - 1);
        date             = method(startW);
        endWIter         = startW;
        nCols            = cellfun(@(x)size(x,2),H);
        nCol             = max(nCols);
        nRow             = size(H{1},1);
        
        % Get the measurment equation for each time period
        HH                 = zeros(nRow,nCol,periods);
        HH(:,1:nCols(1),:) = H{1}(:,:,ones(1,periods));
        while endWIter < endW 
        
            % Which of the measurement equation is correct for this time
            % period?
            num      = getNumberOfWeeks(date);
            ind      = num == divFreq;
            endWIter = getWeek(date,false);
            ii       = (endWIter - startW) + 1;
            
            % Get the measurement equation at the low frequency measurment
            % points
            if ii < periods && ii > 0
                HH(:,1:nCols(ind),ii) = H{ind};
            end
            
            % Iterate
            date = date + 1;
            
        end
        
    else % Three frequencies
        
        periods          = options.estim_end_ind - options.estim_start_ind + 1;
        startW           = nb_date.toDate(options.dataStartDate,52) + (options.estim_start_ind - 1);
        startW.dayOfWeek = options.dayOfWeek;
        endW             = nb_date.toDate(options.dataStartDate,52) + (options.estim_end_ind - 1);
        month            = getMonth(startW);
        endWIter         = startW;
        nCols            = cellfun(@(x)size(x,2),H);
        nCol             = max(nCols);
        nRow             = size(H{1},1);
        
        % Get the measurement equation for each time period
        HH                 = zeros(nRow,nCol,periods);
        HH(:,1:nCols(1),:) = H{1}(:,:,ones(1,periods));
        while endWIter < endW 
        
            % Which of the measurement equation is correct for this time
            % period?
            num      = getNumberOfWeeks(month);
            numQ     = getNumberOfWeeks(getQuarter(month));
            ind      = num == divFreq(:,1) & numQ == divFreq(:,2);
            endWIter = getWeek(month,false);
            ii       = (endWIter - startW) + 1;
            
            % Get the measurment equation at the low frequency measurement
            % points
            if ii < periods && ii > 0
                HH(:,1:nCols(ind),ii) = H{ind};
            end
            
            % Iterate
            month = month + 1;
            
        end
        
    end 

end

%==========================================================================
function [HH,extraAdded] = doMixing(options,H,extraAdded,maxFreq,type,extra)

    % In this case it is secured that the frequency is a number only
    [~,dataFreq]  = nb_date.date2freq(options.dataStartDate);
    freq          = options.frequency(options.indObservedOnly);
    indF          = cellfun(@isempty,freq);
    freq(indF)    = {dataFreq};
    freqD         = [freq{:}];
    mapping       = options.mapping(options.indObservedOnly);
    indM          = cellfun(@isempty,mapping);
    mapping(indM) = {'diffAverage'};
    indOtherFreq  = true(1,size(mapping,2));
    minFreq       = min(freqD);
    if any(ismember({'diffSummed','diffAverage'},mapping))
        type = 2;
    elseif any(ismember({'levelSummed','levelAverage'},mapping))
        type = 3;
    end

    % Adjust options struct to return only the measurment equations of the
    % low frequency mixing variables
    opt           = options;
    nDep          = length(options.dependent);
    indVar        = options.indObservedOnly(1:nDep);
    indBVar       = options.indObservedOnly(nDep + 1:end);
    opt.dependent = options.dependent(indVar);
    if ~isempty(indBVar)
        opt.block_exogenous = options.block_exogenous(indBVar);
        nDep                = nDep + length(opt.block_exogenous);
    end
    opt.indObservedOnly = false(1,nDep);
    
    % Get the measurment equations of the mixing variables
    [G,extraAddedG] = doOnePeriod(opt,freqD,maxFreq,minFreq,type,mapping,indOtherFreq,extra);
    extraAdded      = extraAdded && extraAddedG;
    
    % Combine the measurment equations
    vars = [options.dependent,options.block_exogenous];
    ind  = options.indObservedOnly;
    locH = find(~ind);
    locG = find(ind);
    nH   = size(H,1);
    nG   = size(G,1);
    n    = size(ind,2);
    q    = sum(~ind);
    mH   = size(H,2)/nH;
    mG   = size(G,2)/nG;
    m    = max(mH,mG);
    p    = size(H,3); 
    HH   = zeros(n,m*q,p);
    for ii = 1:size(H,1)
        HH(locH(ii),ii:q:mH*q,:) = H(ii,ii:nH:end,:);
    end
    mixing    = options.mixing(options.indObservedOnly);
    notMixing = vars(~options.indObservedOnly);
    for ii = 1:size(G,1)
        locM = find(strcmpi(mixing{ii},notMixing)); 
        HH(locG(ii),locM:q:mG*q,:) = G(ii,ii:nG:end,:);
    end
    
end

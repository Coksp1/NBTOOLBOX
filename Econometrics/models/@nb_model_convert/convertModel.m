function obj = convertModel(obj)
% Syntax:
%
% obj = convertModel(obj)
%
% Description:
%
% A method for converting the frequency of an nb_model_convert object 
% with forecasts. 
%
% Caution: When converting from high frequency to lowe frequency it
%          uses the same information content, as is the case for the last
%          forecast produced, for all recursive periods. This means that
%          if 2000Q2 is the last forecast start date, then it will fetch
%          the forecast from 1999Q2, 1998Q2, etc...
% 
% Input:
%
% - obj : An object of class nb_model_convert with stored forecasts.
% 
% Output:
% 
% - obj : An object of class nb_model_convert with the converted forecasts.
%
% Written by Tobias Ingebrigtsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Check options
    obj   = check(obj);
    opt   = obj.options;
    freq  = obj.options.freq;
    draws = size(obj.model.forecastOutput.data,3);
    
    % Get forecast and history
    [~,ind]      = ismember(obj.model.forecastOutput.dependent,obj.model.forecastOutput.variables);
    variables    = obj.model.forecastOutput.dependent;
    forecastData = obj.model.forecastOutput.data(:,ind,:,:);
    [~,ind2]     = ismember(obj.model.forecastOutput.dependent,obj.model.options.data.variables);
    historyData  = obj.model.options.data(:,ind2,:,:);
    historyOut   = convert(historyData,freq,opt.method,'interpolateDate',opt.interpolateDate);
    
    % Get nb_date class to use to convert dates
    oldFreq = obj.model.options.data.frequency;     
    switch oldFreq
        case 1
            dateFunc = @(x)nb_year(x);
        case 4
            dateFunc = @(x)nb_quarter(x);
        case 12
            dateFunc = @(x)nb_month(x);
        case 365
            dateFunc = @(x)nb_day(x);
        otherwise
            error([mfilename, ':: Unsupported data frequency.'])  
    end
    
    % Convert each draw
    [newFreqData,start_dates,nowcast,missing] = convertOneDraw(opt,obj.model.forecastOutput,forecastData(:,:,1,:),freq,oldFreq,dateFunc,historyData);
    if draws > 1
        newFreqDataMean = newFreqData;
        newFreqData     = nan(size(newFreqDataMean,1),size(newFreqDataMean,2),size(newFreqDataMean,3),draws);
        for ii = 1:draws-1
            newFreqData(:,:,:,ii) = convertOneDraw(opt,obj.model.forecastOutput,forecastData(:,:,ii,:),freq,oldFreq,dateFunc,historyData);
            if rem(ii,10) == 0
               disp(['Finished with iteration ' int2str(ii)]) 
            end
        end
        newFreqData(:,:,:,end) = newFreqDataMean;
    end
    newFreqData = permute(newFreqData,[1,2,4,3]);
    
    % Save to forecastOutput
    if draws > 1
        draws = draws - 1; % Mean is at one of the pages!
    end
    if nowcast
        nSteps = size(newFreqData,1) - max(sum(missing));
    else
        nSteps = size(newFreqData,1);
    end
    obj.forecastOutput = struct(...
        'data',           newFreqData,...
        'variables',      {variables},...
        'dependent',      {variables},...
        'nSteps',         nSteps,...
        'type',           'unconditional',...
        'start',          {start_dates},...
        'nowcast',        nowcast,...
        'missing',        missing,...
        'evaluation',     struct(),...
        'method',         '',...
        'draws',          draws,...
        'parameterDraws', 1,...
        'regimeDraws',    1,...
        'perc',           [],...
        'inputs',         struct(),...
        'saveToFile',     false);
    
    % Finalize
    obj.historyOutput = historyOut;
    obj.name          = obj.model.name;
    
end

function [newFreqData,start_dates,nowcast,missing] = convertOneDraw(opt,forecastOutput,forecastData,freq,oldFreq,dateFunc,historyData)

    nowcast = 0;
    missing = [];

    % Get the forecast from all forecast periods
    variables = forecastOutput.dependent;
    nVars     = length(variables);
    dates     = forecastOutput.start;
    oldRec    = size(forecastData,4); 
    oldNSteps = size(forecastData,1); 
    if oldFreq > freq
        
        if oldRec > 1
            
            % We correct here so to be sure to use the final
            % forecast for the lower frequency even if the
            % lower frequency is not ended!
            testDate1 = dateFunc(dates{oldRec});
            testDate2 = convert(convert(testDate1,freq),oldFreq);
            incr      = testDate1 - testDate2;
            
            % We only takes the forecasts that has a full period of the 
            % history at the lower frequency
            dataSets = nb_ts;
            if forecastOutput.nowcast
                missing = sum(forecastOutput.missing,1);
                maxM    = max(missing);
                mSteps  = forecastOutput.nSteps;
                for ii = 1:oldRec
                    start = dateFunc(dates{ii});
                    if isFirstPeriod(start - incr,freq) 
                        fcstD = nan(mSteps,nVars);
                        for vv = 1:nVars
                            indF        = 1+maxM-missing(vv):mSteps+maxM-missing(vv);
                            fcstD(:,vv) = forecastData(indF,vv,:,ii);
                        end
                        startH   = convert(convert(start,freq),oldFreq);
                        hist     = window(historyData,startH,start-1);
                        fcst     = nb_ts(fcstD,'',start,variables);
                        fcst     = merge(hist,fcst);
                        dataSets = dataSets.addPages(fcst); 
                    end
                end
            else
                for ii = 1:oldRec
                    start = dateFunc(dates{ii});
                    if isFirstPeriod(start - incr,freq)
                        startH   = convert(convert(start,freq),oldFreq);
                        hist     = window(historyData,startH,start-1);
                        fcst     = nb_ts(forecastData(:,:,:,ii),'',start,variables);
                        fcst     = merge(hist,fcst);
                        dataSets = dataSets.addPages(fcst); 
                    end
                end
            end
            
        else
            
            start = dateFunc(dates{1});
            if isFirstPeriod(start,freq)  % This means that the history is fullfilled at the lower frequency
                fcst = nb_ts(forecastData(:,:,:,1),'',start - forecastOutput.nowcast,variables);
            else
                % We must merge the forecast with history to get the full
                % period of the lower frequency
                start  = start - forecastOutput.nowcast;
                startH = convert(convert(start,freq),oldFreq);
                hist   = window(historyData,startH,start-1);
                fcst   = nb_ts(forecastData(:,:,:,1),'',start,variables);
                fcst   = merge(hist,fcst);
            end
            dataSets = fcst; 
            
        end
        
    elseif oldFreq < freq  
        
        dataSets = nb_ts;
        for ii = 1:oldRec    
            start = dateFunc(dates{ii}) - forecastOutput.nowcast;
            fcst  = nb_ts(forecastData(:,:,:,ii),'',start,variables);
            if strcmpi(opt.interpolateDate,'end') || nb_isScalarInteger(opt.interpolateDate)
                % Used if interpolateDate is end!
                hist = window(historyData,start-1,start-1);
                fcst = merge(hist,fcst); 
            end
            dataSets = dataSets.addPages(fcst);  
        end
        
        if isempty(opt.method)
            opt.method = 'linear';
        end
        
    else
        error([mfilename ':: The same frequency as of the old model is chosen, which is just not necessary!'])
    end
    
    % Do the convertion
    newFreqData = convert(dataSets,freq,opt.method,'interpolateDate',opt.interpolateDate,opt.others{:});
    
    % Get the recursive structure given the new frequency
    if oldFreq < freq  
        
        if oldRec > 1
            
            fill     = nb_parseOneOptional('fill','nan',opt.others{:});
            fillFunc = str2func(fill);
            
            % Now we need to fill in for the subperiod of the low
            % frequency. I.e. if we have yearly data we just have the
            % foreecast as of periods 'yyy1Q1', 'yyy2Q1', but we also 
            % need the forecast as of 'yyy1Q2', 'yyy1Q3',... , and 
            % these are take from the forecast as of 'yyy1Q1'. (But
            % of course this leads to missing forecast at the last
            % periods...)
            if strcmpi(opt.interpolateDate,'end')
                startHigh = convert(dataSets.startDate + 1, freq, true);
                startRec  = startHigh;
            elseif strcmpi(opt.interpolateDate,'start')
                startHigh = convert(dataSets.startDate, freq, true);
                startRec  = startHigh;
            else % interpolateDate is an integer
                startRec    = convert(dataSets.startDate + 1, freq, true);
                startHigh   = startRec;
                expandDate  = convert(convert(newFreqData.endDate,oldFreq),freq,false);
                newFreqData = expand(newFreqData,'',expandDate,fill,'off');
            end
            freqFactor  = freq/oldFreq;
            nSteps      = oldNSteps*freqFactor;
            newFreqTemp = fillFunc(nSteps,newFreqData.numberOfVariables,newFreqData.numberOfDatasets*freqFactor);
            kk          = 1;
            if nb_isScalarInteger(opt.interpolateDate)
                ii = 1;
                while ii <= newFreqData.numberOfDatasets
                    for ff = 1:freqFactor
                        startTemp    = startHigh + (ff-1);
                        startLowHigh = convert(convert(startTemp,oldFreq),freq,false) - opt.interpolateDate;
                        if startTemp == (startLowHigh + 1)
                            ii = ii + 1;
                            if ii > newFreqData.numberOfDatasets
                                break;
                            end
                        end
                        endTemp = startTemp + (nSteps-1);
                        if newFreqData.endDate < endTemp
                            endTemp = newFreqData.endDate;
                        end
                        fcst                   = double(window(newFreqData,startTemp,endTemp,'',ii));
                        hh                     = size(fcst,1);
                        newFreqTemp(1:hh,:,kk) = fcst;
                        kk                     = kk + 1;
                    end
                    startHigh = startHigh + freqFactor;
                end
            else
                for ii = 1:newFreqData.numberOfDatasets
               
                    for ff = 1:freqFactor
                        newFreqTemp(1:end-ff+1,:,kk) = double(window(newFreqData,startHigh + (ff-1),startHigh + (nSteps-1),'',ii));
                        kk = kk + 1;
                    end
                    startHigh = startHigh + freqFactor;

                end
            end
            
            if forecastOutput.nowcast 
                nowcast     = 1;
                missing     = forecastOutput.missing;
                maxM        = max(sum(missing,1));
                freqFactor  = freq/oldFreq;
                ind         = 1:size(missing,1);
                ind         = ind(ones(freqFactor,1),:);
                ind         = ind(:);
                missing     = missing(ind,:);
                corr        = freqFactor*maxM;
            else
                corr = 0;
            end
            
            start_dates = transpose(startRec + corr:newFreqData.endDate - (nSteps - 1 - corr));
            newFreqData = newFreqTemp(:,:,1:length(start_dates));
            
        else
            
            if strcmpi(opt.interpolateDate,'end')
                newFreqData = newFreqData(2:end,:,:);
                startHigh   = newFreqData.startDate;
            elseif nb_isScalarInteger(opt.interpolateDate)
                fill        = nb_parseOneOptional('fill','nan',opt.others{:});
                startHigh   = convert(dataSets.startDate + 1, freq, true);
                expandDate  = convert(convert(newFreqData.endDate,oldFreq),freq,false);
                newFreqData = window(newFreqData,startHigh);
                newFreqData = expand(newFreqData,'',expandDate,fill,'off');   
            else
                startHigh   = newFreqData.startDate;
            end
            
            % Are we dealing with nowcast?
            if forecastOutput.nowcast 
                nowcast     = 1;
                missing     = forecastOutput.missing;
                maxM        = max(sum(missing,1));
                freqFactor  = freq/oldFreq;
                ind         = 1:size(missing,1);
                ind         = ind(ones(freqFactor,1),:);
                ind         = ind(:);
                missing     = missing(ind,:);
                start_dates = {toString(startHigh + (freqFactor*maxM))};
            else
                start_dates = {toString(startHigh)};
            end
            
        end
        
    else
        % Split the sample into the forecast data only
        nRec                  = size(newFreqData.data,3);
        start_dates           = transpose(newFreqData.startDate:newFreqData.startDate+nRec-1);
        nSteps                = floor(oldNSteps*(freq/oldFreq));
        newFreqData.dataNames = transpose(newFreqData.startDate-1:newFreqData.startDate+nRec-2); 
        endDateOfFcst         = nb_date.toDate(newFreqData.dataNames{end},freq) + nSteps;
        newFreqData           = expand(newFreqData,'',endDateOfFcst); % Secure that last fcst is long enough!
        newFreqData           = realTime2RecCondData(newFreqData,nSteps,freq,false,2);
    end
    newFreqData = double(newFreqData);
    
end

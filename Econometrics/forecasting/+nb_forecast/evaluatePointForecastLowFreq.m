function evalFcst = evaluatePointForecastLowFreq(evalFcst,options,Y,dep,model,inputs,start)
% Syntax:
%
% evalFcst = nb_forecast.evaluatePointForecastLowFreq(evalFcst,options,...
%               Y,dep,model,inputs,start)
%
% Description:
%
% Evaluate point forecast of low frequency variable of mixed frequency 
% models.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    fcstEval = inputs.fcstEval;
    if isempty(fcstEval)
       return
    end

    % Keep only the varOfInterest if it is given
    [Y,dep] = nb_forecast.getEvaluatedVariables(Y,dep,model,inputs);
    if isempty(Y)
        return
    end
    
    % Get the unique low frequencies
    vars             = [options.dependent, options.block_exogenous];
    [freqs,startObj] = nb_mfvar.getFrequencyStatic(options,start);
    uFreqs           = unique(freqs);
    highFreq         = max(uFreqs);
    indLow           = uFreqs < highFreq;
    uFreqs           = uFreqs(indLow);
    
    % Evaluate each frequency
    nSteps = size(Y,1);
    for ii = 1:length(uFreqs)

        % Get the variable at this frequency
        varsThisFreq = vars(freqs == uFreqs(ii));
        [~,locV]     = ismember(varsThisFreq,dep);
        [~,locVD]    = ismember(varsThisFreq,options.dataVariables);
        
        % Get indexes of the forecast of lower frequency
        endObj = startObj + (nSteps - 1);
        date   = startObj;
        dateLF = convert(startObj,uFreqs(ii));
        ind    = nan(ceil(nSteps/floor(highFreq/uFreqs(ii))),1);
        kk     = 1;
        while date < endObj
            date   = convert(dateLF,highFreq,false);
            dateLF = dateLF + 1;
            if date > startObj && date < endObj
                ind(kk) = (date - startObj) + 1;
                kk      = kk + 1;
            end
        end
        ind       = ind(~isnan(ind));
        nStepsLow = size(ind,1);
           
        if isempty(locV)
           
            % Set evaluation to nan
            for jj = 1:length(fcstEval)
                % Assign nan for all variables
                evalFcst.([upper(fcstEval{jj}),'_', int2str(uFreqs(ii))]) = nan(nStepsLow,size(Y,2));
            end
            
        else
            
            % Get the actual data to compare against
            if size(options.data,1) < start + nSteps - 1
                app    = nan(start + nSteps - 1 - size(options.data,1),length(locVD));
                actual = [options.data(start:end,locVD); app];
            else
                actual = options.data(start:start + nSteps - 1,locVD);
            end
            
            % Convert the forecast to the lower frequency
            Ylow      = Y(ind,locV);
            actualLow = actual(ind,:);

            % Do the evaluation
            for jj = 1:length(fcstEval)

                % Calculate forecast evaluation
                fcsEvalValue         = nan(nStepsLow,size(Y,2));
                fcsEvalValue(:,locV) = nb_evaluateForecast(fcstEval{jj},actualLow,Ylow);

                % Assign output
                evalFcst.([upper(fcstEval{jj}), '_', int2str(uFreqs(ii))]) = fcsEvalValue;

            end
            
        end
        
    end
    
end

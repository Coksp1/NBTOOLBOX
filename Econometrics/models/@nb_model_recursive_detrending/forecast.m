function obj = forecast(obj,nSteps,varargin)
% Syntax:
%
% obj = forecast(obj,nSteps,varargin)
%
% Description:
%
% Produced recursive conditional point and density forecast of 
% nb_model_recursive_detrending objects.
% 
% Input:
% 
% - obj      : A vector of nb_model_recursive_detrending objects. 
% 
% - nSteps   : See the forecast method of the nb_model_generic class
%
% Optional inputs:
%
% - See the forecast method of the nb_model_generic class
%
% Output:
%
% - obj    : A vector of nb_model_recursive_detrending objects. See the 
%            property forecastOutput.
%  
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = size(obj,1);

    % Separate out some inputs
    [waitbar,varargin] = nb_parseOneOptionalSingle('waitbar',0,1,varargin{:});
    if waitbar
        h    = nb_waitbar([],'Recursive forecast',nobj);
        note = nb_when2Notify(nobj);
    end
    
    indF = find(strcmpi(varargin,'fcstEval'));
    if ~isempty(indF)
        fcstEval = varargin{indF+1};
        if ischar(fcstEval)
            fcstEval = cellstr(fcstEval)';
        end
        varargin = [varargin(1:indF-1),varargin(indF+2:end)];
    end
    
    if any(strcmpi(varargin,'startDate'))
        indSD = find(strcmpi(varargin,'startDate')) + 1;
        if ~isempty(varargin{indSD})
            error([mfilename ':: You cannot use the ''startDate'' option in this setting.'])
        end
    end
    if any(strcmpi(varargin,'endDate'))
        indED = find(strcmpi(varargin,'endDate')) + 1;
        if ~isempty(varargin{indED})
            error([mfilename ':: You cannot use the ''endDate'' option in this setting.'])
        end
    end
    
    names = getModelNames(obj);
    for ii = 1:nobj   
        
        if ~obj(ii).reported
            error([mfilename ':: ' names{ii} ' is not reported. See the checkReporting method.'])
        end
        
        % Produce forecast of each recursive period
        obj(ii).modelIter = forecast(obj(ii).modelIter,nSteps,varargin{:},'estimateDensities',false);
        
        % Get inital forecast struct to store results
        forecastOut = obj(ii).modelIter(1).forecastOutput;
        
        % Merge forecast
        periods      = length(obj(ii).modelIter);
        forecastData = nan(forecastOut.nSteps,length(forecastOut.variables),size(forecastOut.data,3),periods);
        startFcst    = cell(1,periods);
        for tt = 1:periods
            forecastData(:,:,:,tt) = obj(ii).modelIter(tt).forecastOutput.data;
            startFcst(tt)          = obj(ii).modelIter(tt).forecastOutput.start;
        end
        forecastOut.data  = forecastData;
        forecastOut.start = startFcst;
        
        % Get actual from last iteration
        actual         = window(obj(ii).modelIter(end).options.data,forecastOut.start{1},'',forecastOut.dependent);
        actual         = reorder(actual,forecastOut.dependent);
        actual         = double(actual);
        shiftVars      = obj(ii).modelIter(end).options.shift.variables;
        [ind,locS]      = ismember(shiftVars,forecastOut.dependent);
        locS           = locS(ind);
        shift          = double(window(obj(ii).modelIter(end).options.shift,forecastOut.start{1},obj(ii).modelIter(end).options.data.endDate));
        actual(:,locS) = actual(:,locS) + shift(:,ind);
        actual         = [actual;nan(1,size(actual,2))]; %#ok<AGROW>
        actual         = nb_splitSample(actual,forecastOut.nSteps);
        
        % Evaluate forecast
        if size(forecastOut.data,3) == 1 
            evalFcst = evaluatePoint(forecastData,actual,fcstEval);
        else
            evalFcst = evaluateDensity(forecastData,actual,fcstEval,forecastOut.saveToFile,ii);
        end
        forecastOut.evaluation = evalFcst;
        obj(ii).forecastOutput = forecastOut;
        
        if waitbar
            if rem(ii,note) == 0
                h.status = h.status + note;
                h.text   = ['Forecasting of Model '  int2str(ii) ' of ' int2str(nobj) ' finished.']; 
                drawnow;
            end
        end
        
    end

end

% SUB
%======================================================================
function evalFcst = evaluatePoint(fcst,actual,fcstEval)

    if ~isempty(fcstEval)
        
        evalFcst = cell(1,size(fcst,4));
        for tt = 1:size(fcst,4)
            for ii = 1:length(fcstEval)
                fcsEvalValue = nb_evaluateForecast(fcstEval{ii},actual(:,:,tt),fcst(:,:,:,tt));
                evalFcst{tt}.(upper(fcstEval{ii})) = fcsEvalValue;
            end
        end
        evalFcst = [evalFcst{:}];

    end
    
end

%==========================================================================
function evalFcst = evaluateDensity(fcst,actual,fcstEval,saveToFile,index)

    if ~isempty(fcstEval)
        
        evalFcst = cell(1,size(fcst,4));
        for tt = 1:size(fcst,4)
            for ii = 1:length(fcstEval)
                evalFcst{tt} = nb_evaluateDensityForecast(fcstEval,actual(:,:,tt),fcst(:,:,2:end-1,tt),fcst(:,:,end,tt));
            end
        end
        evalFcst = [evalFcst{:}];

    end
    
    % Some properties may be to memory intensive, so we can save does to 
    % files and store the path to the file instead
    if saveToFile
        
        density    = {evalFcst.density}; %#ok<NASGU>
        domain     = {evalFcst.int}; %#ok<NASGU>
        pathToSave = nb_userpath('gui');

        if exist(pathToSave,'dir') ~= 7
            try
                mkdir(pathToSave)
            catch %#ok<CTCH>
                error(['You are standing in a folder you do not have writing access to (' pathToSave '). Please switch user path!'])
            end
        end
        
        saveND = ['\density_model_' int2str(index) '_' nb_clock('vintagelong')];
        saveND = [pathToSave '\' saveND];
        save(saveND,'domain','density')

        % Assign output the filename (I think this is the fastest way to 
        % do it)
        nPer                  = size(evalFcst,2);
        saveND                = cellstr(saveND);
        saveND                = saveND(:,ones(1,nPer));
        [evalFcst(:).int]     = saveND{:};
        [evalFcst(:).density] = saveND{:};
        
    end
    
end

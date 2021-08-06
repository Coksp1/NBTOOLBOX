function obj = doTest(obj)
% Syntax:
%
% obj = doTest(obj)
%
% Description:
%
% Do the Bai-Perron structural break test. Results are stored in the 
% property results.
% 
% Input:
% 
% - obj : An object of class nb_baiPerronTestStatistic.
% 
% Output:
% 
% - obj : An object of class nb_baiPerronTestStatistic.
%
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(obj.data,'nb_ts')
        error([mfilename ':: The data property must be an object of class nb_ts.'])
    end
    opt = obj.options;
    
    % Check inputs
    %--------------------------------------------------------------
    data   = obj.data;
    start  = opt.startDate;
    if isempty(start)
        start = data.startDate;
    else
        start = nb_date.toDate(start,data.frequency);
    end
    
    finish = opt.endDate;
    if isempty(finish)
        finish = data.endDate;
    else
        finish = nb_date.toDate(finish,data.frequency);
    end

    % Get the data
    try
        y = getVariable(data,opt.dependent,start,finish,1);
    catch %#ok<CTCH>
        if any(strcmpi(opt.dependent,data.variables))
            error([mfilename ':: Wrong input given to the ''dependent'' option.'])
        else
            error([mfilename ':: The dependent variable ' opt.dependent ' is not part of the data property.'])
        end
    end
    if size(y,1) < 11
        error([mfilename ':: The sample length must at least be 11 periods.'])
    end
    
    if isempty(opt.exogenous)
        z = nan(size(y,1),0);
    else
        try
            z = window(data,start,finish,opt.exogenous,1).data;
        catch %#ok<CTCH>
            if iscellstr(opt.exogenous)
                ind = ismember(opt.exogenous,data.variables);
            else
                error([mfilename ':: Wrong input given to the ''exogenous'' option. Must be set to a cellstr.'])
            end
            if all(ind)
                error([mfilename ':: Wrong input given to the ''exogenous'' option.'])
            else
                error([mfilename ':: The exogenous variable(s) ' toString(opt.exogenous(~ind)) ' is not part of the data property.'])
            end
        end
    end
    
    if opt.time_trend 
        tt = 1:size(z,1);
        z  = [tt',z];
    end
    if opt.constant 
        z = [ones(size(z,1),1),z];
    end
    if isempty(z)
        error([mfilename ':: Some regressors must be choosen!'])
    end
    
    if isempty(opt.fixed)
        x = [];
    else
        try
            x = window(data,start,finish,opt.fixed,1).data;
        catch %#ok<CTCH>
            if iscellstr(opt.fixed)
                ind = ismember(opt.fixed,data.variables);
            else
                error([mfilename ':: Wrong input given to the ''fixed'' option. Must be set to a cellstr.'])
            end
            if all(ind)
                error([mfilename ':: Wrong input given to the ''fixed'' option.'])
            else
                error([mfilename ':: The fixed variable(s) ' toString(opt.fixed(~ind)) ' is not part of the data property.'])
            end
        end
    end
    
    if ~nb_isScalarInteger(opt.maxNumBreaks)
        error([mfilename ':: The maximum number of breaks (''maxNumBreaks'') option must be an integer.'])
    end
    
    eps1 = opt.critical;
    ind  = ismember(eps1,[0.05,0.1,0.15,0.2,0.25]);
    if ~ind
        error([mfilename ':: The ''critical'' option must be set to 0.05, 0.1, 0.15, 0.2 or 0.25.'])
    end
    if opt.maxNumBreaks > 10
        error([mfilename ':: The maximum number of breaks (''maxNumBreaks'') option cannot exceed 10.'])
    elseif opt.maxNumBreaks>8 && eps1>0.05
        error([mfilename ':: The ''critical'' option must be set to 0.05 if the maximum number of breaks (''maxNumBreaks'') are set to a number greater than 8.'])
    elseif opt.maxNumBreaks>5 && eps1>0.1
        error([mfilename ':: The ''critical'' option must be set to 0.05 or 0.1 if the maximum number of breaks (''maxNumBreaks'') are set to a number greater than 5.'])
    elseif opt.maxNumBreaks>3 && eps1>0.15
        error([mfilename ':: The ''critical'' option must be set to 0.05, 0.1 or 0.15 if the maximum number of breaks (''maxNumBreaks'') are set to a number greater than 3.'])
    elseif opt.maxNumBreaks>2 && eps1>0.2
        error([mfilename ':: The ''critical'' option must be set to 0.05, 0.1, 0.15 or 0.2 if the maximum number of breaks (''maxNumBreaks'') are set to a number greater than 2.'])
    end
    
    if isempty(opt.minSegment)
        opt.minSegment = max(round(eps1*size(y,1)),5);
    end
    if opt.minSegment < 5
        error([mfilename ':: The ''minSegment'' input must be greater than 4.'])
    end
    
    test = [y,z];
    if ~isempty(x)
        test = [test,x];
    end
    if any(isnan(test(:)))
        error([mfilename ':: The dataset must be balanced!'])
    end
    
    % Do test
    %----------------------------------------------------------------
    try
        obj.results = baiPerron.pbreak(y,z,x,opt.maxNumBreaks,opt.minSegment,eps1,...
                         opt.robust,opt.prewhit,opt.hetomega,opt.hetq,...
                         opt.criterion,opt.estimseq,opt.estimrep,opt.eps,...
                         opt.maxi,opt.initBeta,opt.printd,opt.hetdat,...
                         opt.hetvar);
    catch
        error([mfilename ':: The bai-perron test is not part of this version of NB toolbox.'])
    end
    
end

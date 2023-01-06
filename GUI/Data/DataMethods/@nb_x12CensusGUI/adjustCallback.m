function adjustCallback(gui,hObject,~)
% Syntax:
%
% adjustCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get options
    %------------
    index = get(gui.pop1,'value');
    switch index
        case 1
            output = 'seasadj';
        case 2
            output = 'seasonal';
        case 3
            output = 'trendcycle';
        case 4
            output = 'irregular';
        case 5
            output = 'missingvaladj';
    end
    
    index  = get(gui.pop2,'value');
    switch index
        case 1
            mode = 'auto';
        case 2
            mode = 'mult';
        case 3
            mode = 'add';
        case 4
            mode = 'logadd';
        case 5
            mode = 'pseudoadd';
    end
    
    index = get(gui.pop3,'value');
    switch index
        case 1
            dummyType = 'holiday';
        case 2
            dummyType = 'td';
    end
    
    tDays = get(gui.rb1,'value');
    
    string  = get(gui.edit1,'string');
    maxIter = round(str2double(string));
    if isnan(maxIter)
        nb_errorWindow('The max iteration option must be a number greater the 0.')
        return
    elseif maxIter <= 0
        nb_errorWindow('The max iteration option must be a number greater the 0.')
        return
    end
    
    missing = get(gui.rb2,'value');
    logInd  = get(gui.rb3,'value');
    postfix = get(gui.edit2,'string');
    
    temp  = double(gui.data);
    isNaN = isnan(temp(:));
    if any(isNaN)  
        if ~missing
            nb_errorWindow('You have missing observations, but you have not indicated so.')
            return
        end
    end
    
    % Interpret the data options
    start  = nb_getUIControlValue(gui.edit3);
    finish = nb_getUIControlValue(gui.edit4);
    s      = 1;
    f      = gui.data.numberOfObservations;
    if ~isempty(start)
        try
            s = nb_date.toDate(start,gui.data.frequency);
        catch %#ok<CTCH>
            nb_errorWindow('The start date provided is not on the correct date format.')
        end
        s = (s - gui.data.startDate) + 1;
        if s > gui.data.numberOfObservations || s < 1
            nb_errorWindow(['The end date given is outside the window of the data; ' toString(gui.data.startDate) ' - ' toString(gui.data.endDate)])
        end
    end
    if ~isempty(finish)
        try
            f = nb_date.toDate(finish,gui.data.frequency);
        catch %#ok<CTCH>
            nb_errorWindow('The end date provided is not on the correct date format.')
        end
        f = (f - gui.data.startDate) + 1;
        if f > gui.data.numberOfObservations || f < 1
            nb_errorWindow(['The end date given is outside the window of the data; ' toString(gui.data.startDate) ' - ' toString(gui.data.endDate)])
        end
    end
    periods = f - s + 1;
    if periods > 70*gui.data.frequency
        nb_errorWindow(['This method cannot handle time-series with length of more than 70 years. The length is ' int2str(ceil(periods/gui.data.frequency)) ' years.'])
        return
    end

    % Narrow to the variables of interest
    %------------------------------------
    allVars = get(gui.list1,'string');
    ind     = get(gui.list1,'value');
    vars    = allVars(ind);
    
    inputs = {...
        'output',       output,...
        'mode',         mode,...
        'dummyType',    dummyType,...
        'tdays',        tDays,...
        'maxIter',      maxIter,...
        'missing',      missing,...
        'log',          logInd,...
        'startDate',    start,...
        'endDate',      finish};
        
    % Add postfix
    %------------
    if get(gui.rball,'value') && isempty(postfix)
        % Call x12 filter
        try
            gui.data = x12Census(gui.data, inputs{:});
        catch Err
            nb_errorWindow('x12Census failed with error: ',Err)
            return
        end
    else
        
        if isempty(postfix)
            nb_errorWindow('The postfix cannot be empty.')
            return
        end
        message = nb_checkPostFix(postfix);
        if ~isempty(message)
            nb_errorWindow(message);
            return
        end
        try
            gui.data = extMethod(gui.data,'x12Census',vars,postfix,inputs{:});
        catch Err
            nb_errorWindow('x12Census failed with error: ',Err)
            return
        end

    end
        
    % Notify listeners
    %-----------------
    notify(gui,'methodFinished');
    
    % Close GUI window
    %-----------------
    close(get(get(hObject,'parent'),'parent'));

end

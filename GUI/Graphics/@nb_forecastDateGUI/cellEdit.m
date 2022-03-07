function cellEdit(gui,hObject,event)
% Syntax:
%
% cellEdit(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    plotterA = gui.plotter;
    if isempty(event.Error)
    
        % Get the selected date
        %----------------------------------------------------------
        date = event.EditData;
        if ~strcmpi(date,'start')
            if ~nb_contains(date,'%#')

                try
                    nb_date.date2freq(date);
                catch %#ok<CTCH>
                    nb_errorWindow(['Unsupported date format ''' date '''.']);
                    return
                end

            else

                dateT = nb_localVariables(plotterA.localVariables,date);
                try
                    nb_date.date2freq(dateT);
                catch %#ok<CTCH>
                    if strcmpi(dateT,date)
                        nb_errorWindow(['Undefined local variable ' date '.']);
                    else
                        nb_errorWindow(['Unsupported date format ''' dateT ''' defined ',...
                            'by the local variable ' date '.']);
                    end
                    return
                end

            end
        end
        
        % Assign changes
        %----------------------------------------------------------
        ind           = event.Indices(1);
        ind2          = event.Indices(2);
        dat           = get(hObject,'data');
        dat{ind,ind2} = date;
        set(hObject,'data',dat);
        
        var           = dat{ind,1};
        old           = plotterA.forecastDate;
        indV          = find(strcmp(var,old),1,'last');
        if isempty(indV)
            new = [old, var,date];
        else
            if ~isempty(date)
                new = old;
                new{indV + 1} = date;
            else
                new = [old(1:indV-1),old(indV+2:end)];
            end
        end
        plotterA.forecastDate = new;
        
        % Notify listeners
        notify(gui,'changedGraph');
        
    else
        nb_errorWindow('Error while edit the selected cell of the table') 
    end

end

function exportTextStruct(gui,~,~)
% Syntax:
%
% saveToSession(gui,~,~)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    graphInfo = gui.infoStruct;
    
    % Get chosen name and destination
    [file,path] = uiputfile('*.mat');
    
    % Cancelled by user
    if file == 0
        return
    end
    
    time = nb_clock();
    
    % We know the length of the extension so index directly
    chosenName = file(1:end-4);
    extension  = file(end-3:end);
    
    % Concatinate to full path with chosen name and date + time
    fullName = [path,chosenName,'_',time,extension];
    
    save(fullName, 'graphInfo');

end

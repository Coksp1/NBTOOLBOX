function setTextInfo(gui,~,~)
% Syntax:
%
% setTextInfo(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    sGraphObj = gui.infoStruct.(gui.name);
    
    % Norwegian Figure Name
    strNor = get(gui.editBox1,'string');
    gui.infoStruct.(gui.name).figureNameNor = strNor;
    
    % English Figure Name
    strEng = get(gui.editBox2,'string');
    gui.infoStruct.(gui.name).figureNameEng = strEng;
    
    % Norwegian Figure Title
    strNor = get(gui.editBox3,'string');
    gui.infoStruct.(gui.name).figureTitleNor = cellstr(strNor);
    
    % English Figure Title
    strEng = get(gui.editBox4,'string');
    gui.infoStruct.(gui.name).figureTitleEng = cellstr(strEng);
    
    % Norwegian Footer
    strNor = get(gui.editBox5,'string');
    gui.infoStruct.(gui.name).footerNor = cellstr(strNor);
    
    % English Footer
    strEng = get(gui.editBox6,'string');
    gui.infoStruct.(gui.name).footerEng = cellstr(strEng);
    
    % Norwegian Tooltip
    strNor = get(gui.editBox7,'string');
    gui.infoStruct.(gui.name).tooltipNor = cellstr(strNor);
    
    % English Tooltip
    strEng = get(gui.editBox8,'string');
    gui.infoStruct.(gui.name).tooltipEng = cellstr(strEng);    
    
    
    if ~sGraphObj.panel
        
        % Norwegian Excel Title
        strNor = get(gui.editBox9,'string');
        gui.infoStruct.(gui.name).excelTitleNor = cellstr(strNor);

        % English Excel Title
        strEng = get(gui.editBox10,'string');
        gui.infoStruct.(gui.name).excelTitleEng = cellstr(strEng);

        % Norwegian Excel Footer
        strNor = get(gui.editBox11,'string');
        gui.infoStruct.(gui.name).excelFooterNor = cellstr(strNor);

        % English Excel Footer
        strEng = get(gui.editBox12,'string');
        gui.infoStruct.(gui.name).excelFooterEng = cellstr(strEng);
        
    else
        % Panel 1
        
        % Norwegian Figure Title
        strNor = get(gui.editBox9,'string');
        gui.infoStruct.(gui.name).excelTitleNor_1 = cellstr(strNor);

        % English Figure Title
        strEng = get(gui.editBox10,'string');
        gui.infoStruct.(gui.name).excelTitleEng_1 = cellstr(strEng);

        % Norwegian Footer
        strNor = get(gui.editBox11,'string');
        gui.infoStruct.(gui.name).excelFooterNor_1 = cellstr(strNor);

        % English Footer
        strEng = get(gui.editBox12,'string');
        gui.infoStruct.(gui.name).excelFooterEng_1 = cellstr(strEng);
        
        % Panel 2
        
        % Norwegian Figure Title
        strNor = get(gui.editBox13,'string');
        gui.infoStruct.(gui.name).excelTitleNor_2 = cellstr(strNor);

        % English Figure Title
        strEng = get(gui.editBox14,'string');
        gui.infoStruct.(gui.name).excelTitleEng_2 = cellstr(strEng);

        % Norwegian Footer
        strNor = get(gui.editBox15,'string');
        gui.infoStruct.(gui.name).excelFooterNor_2 = cellstr(strNor);

        % English Footer
        strEng = get(gui.editBox16,'string');
        gui.infoStruct.(gui.name).excelFooterEng_2 = cellstr(strEng);
        
    end

end

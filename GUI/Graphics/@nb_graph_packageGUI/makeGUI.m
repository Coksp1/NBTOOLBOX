function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Create the main window
    %------------------------------------------------------
    gui.figureHandle = nb_guiFigure(gui.parent,'Graph Package:',[40   15  85.5   31.5],'normal','off',@gui.close);

    % Set up the menu
    %------------------------------------------------------
    gui.packageMenu = uimenu(gui.figureHandle,'label','File');
        uimenu(gui.packageMenu,'Label','Save',   'Callback',@gui.save);
        uimenu(gui.packageMenu,'Label','Save as','Callback',@gui.saveAs);
        uimenu(gui.packageMenu,'Label','Rename Package', 'separator','on','Callback',@gui.renamePackage);
        uimenu(gui.packageMenu,'Label','Export', 'separator','on', 'Callback',@gui.export);
        
    gui.graphMenu = uimenu(gui.figureHandle,'label','Graph');
        uimenu(gui.graphMenu,'Label','Add',     'Callback',@gui.add);
        uimenu(gui.graphMenu,'Label','Delete',  'Callback',@gui.deleteCallback);
        uimenu(gui.graphMenu,'Label','Reorder', 'Callback',@gui.reorder);

    gui.methodsMenu = uimenu(gui.figureHandle,'label','Methods');
        preview = uimenu(gui.methodsMenu,'Label','Preview');
            uimenu(preview,'Label','English',   'Callback',{@gui.preview,'english'},   'accelerator','E');
            uimenu(preview,'Label','Norwegian', 'Callback',{@gui.preview,'norwegian'}, 'accelerator','N');
        preview = uimenu(gui.methodsMenu,'Label','Preview (incl. text)');
            uimenu(preview,'Label','English',   'Callback',{@gui.preview,'english',true});
            uimenu(preview,'Label','Norwegian', 'Callback',{@gui.preview,'norwegian',true});
        saveM1  = uimenu(gui.methodsMenu,'Label','Save to PDF');
            uimenu(saveM1,'Label','English',    'Callback',{@gui.saveToPDF,'english'});
            uimenu(saveM1,'Label','Norwegian',  'Callback',{@gui.saveToPDF,'norwegian'});
        saveM1  = uimenu(gui.methodsMenu,'Label','Save to PDF (incl. text)');
            uimenu(saveM1,'Label','English',    'Callback',{@gui.saveToPDF,'english',true});
            uimenu(saveM1,'Label','Norwegian',  'Callback',{@gui.saveToPDF,'norwegian',true});    
        saveM2  = uimenu(gui.methodsMenu,'Label','Save to separate PDFs');
            uimenu(saveM2,'Label','English (Numbering)',    'Callback',@(h,e)gui.save2Separate(h,e,'english','pdf',true));
            uimenu(saveM2,'Label','Norwegian (Numbering)',  'Callback',@(h,e)gui.save2Separate(h,e,'norwegian','pdf',true));
            uimenu(saveM2,'Label','English',                'Callback',@(h,e)gui.save2Separate(h,e,'english','pdf',false));
            uimenu(saveM2,'Label','Norwegian',              'Callback',@(h,e)gui.save2Separate(h,e,'norwegian','pdf',false));
        saveM3  = uimenu(gui.methodsMenu,'Label','Save to separate PDFs (incl. text)');
            uimenu(saveM3,'Label','English (Numbering)',    'Callback',@(h,e)gui.save2Separate(h,e,'english','pdfext',true));
            uimenu(saveM3,'Label','Norwegian (Numbering)',  'Callback',@(h,e)gui.save2Separate(h,e,'norwegian','pdfext',true));
            uimenu(saveM3,'Label','English',                'Callback',@(h,e)gui.save2Separate(h,e,'english','pdfext',false));
            uimenu(saveM3,'Label','Norwegian',              'Callback',@(h,e)gui.save2Separate(h,e,'norwegian','pdfext',false));    
        saveM4  = uimenu(gui.methodsMenu,'Label','Save to separate EMFs');
            uimenu(saveM4,'Label','English (Numbering)',    'Callback',@(h,e)gui.save2Separate(h,e,'english','emf',true));
            uimenu(saveM4,'Label','Norwegian (Numbering)',  'Callback',@(h,e)gui.save2Separate(h,e,'norwegian','emf',true));
            uimenu(saveM4,'Label','English',                'Callback',@(h,e)gui.save2Separate(h,e,'english','emf',false));
            uimenu(saveM4,'Label','Norwegian',              'Callback',@(h,e)gui.save2Separate(h,e,'norwegian','emf',false));
        saveM5  = uimenu(gui.methodsMenu,'Label','Save to separate TXTs');
            saveM5a = uimenu(saveM5,'Label','English (Numbering)');
                uimenu(saveM5a,'Label','One folder','Callback',@(h,e)gui.save2Separate(h,e,'english','txt',true,true));
                uimenu(saveM5a,'Label','Separate folders','Callback',@(h,e)gui.save2Separate(h,e,'english','txt',true,false));
            saveM5b = uimenu(saveM5,'Label','Norwegian (Numbering)');
                uimenu(saveM5b,'Label','One folder','Callback',@(h,e)gui.save2Separate(h,e,'norwegian','txt',true,true));
                uimenu(saveM5b,'Label','Separate folders','Callback',@(h,e)gui.save2Separate(h,e,'norwegian','txt',true,false));
            saveM5c = uimenu(saveM5,'Label','English');
                uimenu(saveM5c,'Label','One folder','Callback',@(h,e)gui.save2Separate(h,e,'english','txt',false,true));
                uimenu(saveM5c,'Label','Separate folders','Callback',@(h,e)gui.save2Separate(h,e,'english','txt',false,false));
            saveM5d = uimenu(saveM5,'Label','Norwegian'); 
                uimenu(saveM5d,'Label','One folder','Callback',@(h,e)gui.save2Separate(h,e,'norwegian','txt',false,true));
                uimenu(saveM5d,'Label','Separate folders','Callback',@(h,e)gui.save2Separate(h,e,'norwegian','txt',false,false));
        saveM6  = uimenu(gui.methodsMenu,'Label','Save to Excel');
            uimenu(saveM6,'Label','English',    'Callback',{@gui.saveToExcel,'english'});
            uimenu(saveM6,'Label','Norwegian',  'Callback',{@gui.saveToExcel,'norwegian'});
            uimenu(saveM6,'Label','Both',       'Callback',{@gui.saveToExcel,'both'});
        saveM7 = uimenu(gui.methodsMenu,'Label','Save for MPR'); 
            uimenu(saveM7,'Label','Save all','Callback',@gui.saveForMPR);
        uimenu(gui.methodsMenu,'Label','View spreadsheet','Callback',@gui.viewInfoSpreadsheetCallback);
       % saveM5  = uimenu(gui.methodsMenu,'Label','Excel Change Log');
       %     uimenu(saveM5,'Label','Import', 'Callback',{@gui.excelChangeLogGUI,'import'});
       %     uimenu(saveM5,'Label','Export', 'Callback',{@gui.excelChangeLogGUI,'export'});            
        uimenu(gui.methodsMenu,'Label','Update','separator','on','Callback',@gui.update);
        uimenu(gui.methodsMenu,'Label','Help','separator','on','Callback',@gui.helpMethodsGPCallback);
   
    isNB = false;
    try %#ok<TRYNC>
        isNB = nb_is(); 
    end 
    
    gui.propertiesMenu = uimenu(gui.figureHandle,'label','Properties');   
            uimenu(gui.propertiesMenu,'Label','Chapter',            'Callback',@gui.chapter);
            uimenu(gui.propertiesMenu,'Label','Big Letter Counting','Callback',@gui.bigLetterCallback,'checked',nb_onOff(gui.package.bigLetter));
            uimenu(gui.propertiesMenu,'Label','Start',              'Callback',@gui.start);
            uimenu(gui.propertiesMenu,'Label','Title',              'Callback',@gui.title);
            uimenu(gui.propertiesMenu,'Label','Subtitle',           'Callback',@gui.subtitle);
            uimenu(gui.propertiesMenu,'Label','Round-off',          'Callback',@gui.setRoundoff);
            uimenu(gui.propertiesMenu,'Label','Flip PDF',           'Callback',@gui.flipPDF,'checked',nb_onOff(gui.package.flip));
            uimenu(gui.propertiesMenu,'Label','A4 format',          'Callback',@gui.a4PortraitCallback,'checked',nb_onOff(gui.package.a4Portrait));
            uimenu(gui.propertiesMenu,'Label','Advanced',           'Callback',@gui.advancedCallback,'checked',nb_onOff(gui.package.advanced));
            
        if isNB
            % Check the round-off status
            uimenu(gui.propertiesMenu,'Label','MPR Style',        'Callback',@gui.setExcelStyle,'checked',nb_onOff(strcmpi(gui.package.excelStyle,'mpr')));
            uimenu(gui.propertiesMenu,'Label','Zero Lower Bound', 'Callback',@gui.setZeroLowerBound,'checked',nb_onOff(gui.package.zeroLowerBound));
        end
        
        uimenu(gui.propertiesMenu,'Label','Help','separator','on','Callback',@gui.helpPropertiesGPCallback);
        
    %gui.templateMenu = uimenu(gui.figureHandle,'label','Template');   
    %    uimenu(gui.templateMenu,'Label','Choose...', 'Callback',@gui.templateCallback);
    %    uimenu(gui.templateMenu,'Label','Help', 'Callback',@gui.helpTemplateGPCallback,'separator','on');
        
    % Create graph list
    gui.graphList = uicontrol(nb_constant.LISTBOX,...
             'position',    [0.04, 0.04, 0.92, 0.92],...
             'parent',      gui.figureHandle,...
             'value',       1); 
    gui.updateGUI();    
         
    % Set the window visible   
    %--------------------------------------------------------------
    set(gui.figureHandle,'visible','on');

end


function saveToFile(gui,~,~)
% Syntax:
%
% saveToFile(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Settings (should be provided from the user) 
    %------------------------------------------------------
    transparent =  1; 
    crop        =  get(gui.rb3,'value');
    flipPage    =  get(gui.rb1,'value');
    pdfBook     =  get(gui.rb2,'value');
    forPPT      =  get(gui.rb5,'value');
    if get(gui.rb4,'value')
        crop = 1;
    end

    % Get the selected file name
    %------------------------------------------------------
    filename = get(gui.edit1,'string');
    
    if isempty(filename)
        nb_errorWindow('You must provide a file name/path.')
        return
    end
    
    % Get extension
    %--------------------------------------------------
    [pathname,filename] = fileparts(filename);

    % Get selected file type
    string   = get(gui.pop1,'string');
    index    = get(gui.pop1,'value');
    selected = string{index};

    switch selected

        case 'Portable document format (*.pdf)'
            newExt = 'pdf';
        case 'Enhanced metafile (*.emf)'
            newExt = 'emf';
        case 'Portable network format (*.png)'
            newExt = 'png';
        case 'Encapsulated postscript (*.eps)'
            newExt = 'eps';
        case 'Joint Photographic Group (*.jpg)'
            newExt = 'jpg';
        case 'Scalable Vector Graphics (*.svg)'
            newExt = 'svg';
        case 'MATLAB Object (*.mat)'
            newExt = 'mat';
        case 'MATLAB Script (*.m)'
            newExt = 'm';
        case 'MATLAB fig file (*.fig)'
            newExt = 'fig';    
        otherwise
            error([mfilename ':: It should be impossible to select a non-existing file type.'])
    end

    % Construct the save name
    if isempty(pathname)
        pathname = pwd;
    end
    saveName = [pathname,'\',filename];
    filename = [pathname,'\',filename,'.',newExt]; 
    
    % First we need to prepare figure stuff
    %--------------------------------------------------------------
    inputs = {};
    if strcmpi(newExt,'emf') && forPPT 
         
        pos    = nan(1,4);
        pos(1) = nb_getUIControlValue(gui.cropBoxes(1),'numeric');
        pos(2) = nb_getUIControlValue(gui.cropBoxes(2),'numeric');
        pos(3) = nb_getUIControlValue(gui.cropBoxes(3),'numeric');
        pos(4) = nb_getUIControlValue(gui.cropBoxes(4),'numeric');
        if any(isnan(pos))
            nb_errorWindow('The cropping coordinates must be numbers strictly between 0 and 1.')
            return
        elseif any(pos >= 1) || any(pos <= 0)
            nb_errorWindow('The cropping coordinates must be numbers strictly between 0 and 1.')
            return
        end
        if isa(gui.plotter,'nb_graph_adv')
            
            oldNor = gui.plotter.figureTitleNor;
            oldEng = gui.plotter.figureTitleEng;
            gui.plotter.set('figureTitleNor' ,'');
            gui.plotter.set('figureTitleEng' ,'');
            
            oldPos = gui.plotter.plotter.position;
            set(gui.plotter.plotter,'position',pos);
            oldDefaultFigureNumbering = gui.plotter.plotter.defaultFigureNumbering;
            setSpecial(gui.plotter.plotter,'defaultFigureNumbering',false);
            graph(gui.plotter.plotter);
        else
            oldPos = gui.plotter.position;
            set(gui.plotter,'position',pos);
            graph(gui.plotter);
        end
        
    end
    if ~(strcmpi(newExt,'mat') || strcmpi(newExt,'m') || strcmpi(newExt,'fig'))

        % Scale figure to remove most of the white space 
        % around the figure
        if isa(gui.plotter,'nb_graph_adv')
            fig = get(gui.plotter.plotter,'figureHandle');
        else
            fig = get(gui.plotter,'figureHandle');
        end
        matFig = fig.figureHandle;
        posF   = get(matFig,'position');
        unitF  = get(matFig,'units');

        if isa(gui.plotter,'nb_graph_adv')
            set(matFig,'position',[posF(1)   posF(2)  220   48.3846]);
            %set(matFig,'position',[posF(1)   posF(2)  130   29]);
            for ii = 1:length(gui.plotter.plotter)
                gui.plotter.plotter(ii).axesScaleLineWidth = true;
                gui.plotter.plotter(ii).axesScaleFactor    = 0.8;
                gui.plotter.plotter(ii).graph();
            end
        else
            set(matFig,'position',[posF(1)   posF(2)  186.4   41.3846]);
        end

        % Parse options
        if ~flipPage
            if strcmpi(newExt,'pdf')
                inputs = {'-noflip'}; % This is correct!!
            else
                paperSize = get(matFig,'PaperSize');
                set(matFig,'PaperSize',fliplr(paperSize)); 
            end
        end

    end

    % Save to files 
    %--------------------------------------------------------------
    switch lower(newExt)

        case 'pdf'

            inputs = [inputs, {'-painters'}];
            if pdfBook
                if exist(filename,'file') == 2
                    inputs = [inputs, '-append'];
                end
            end
            if transparent 
                inputs = [inputs, '-transparent'];
            end
            if ~crop
                inputs = [inputs, '-nocrop'];
            end

            try
                nb_saveas(matFig,saveName,'pdf',inputs{:});
            catch Err
                nb_errorWindow('Could not save the figure to PDF.',Err)
            end
            
        case 'svg'

            set(matFig,...
                'paperPositionMode',    'auto',...
                'renderer',             'painters', ...
                'invertHardcopy',       'off');
            try
                plot2svg(filename,matFig)
            catch Err
                nb_errorWindow('Could not save the figure to SVG.',Err)
            end

        case 'emf'

            set(matFig,...
                'paperPositionMode',    'auto',...
                'renderer',             'painters', ...
                'invertHardcopy',       'off');
            try
                print(matFig,'-dmeta',filename)
            catch Err
                nb_errorWindow('Could not save the figure to EMF.',Err)
            end

        case 'eps'

            set(matFig,...
                'paperPositionMode',    'auto',...
                'renderer',             'painters', ...
                'invertHardcopy',       'off');
            try
                print(matFig,'-depsc','-tiff','-r300',filename)
            catch Err
                nb_errorWindow('Could not save the figure to EPS.',Err)
            end

        case 'jpg'

            inputs = {'-jpg','-opengl'};

            if transparent 
                inputs = [inputs, '-transparent'];
            end

            if ~crop
                inputs = [inputs, '-nocrop'];
            end

            try
                export_fig(matFig,saveName,inputs{:});
            catch Err
                nb_errorWindow('Could not save the figure to JPG.',Err)
            end

        case 'png'

            inputs = {'-png','-opengl'};

            if transparent 
                inputs = [inputs, '-transparent'];
            end

            if ~crop
                inputs = [inputs, '-nocrop'];
            end

            %system('gswin64c -o -q -sDEVICE=png256 -dEPSCrop -r300 -oimprovedExample_eps.png improvedExample.eps');
            try
                export_fig(matFig,saveName,inputs{:});
            catch Err
                nb_errorWindow('Could not save the figure to PNG.',Err)
            end

        case 'mat'

            % Save down graph as MATLAB object
            plotObj = copy(gui.plotter); 
            save(saveName,'plotObj');
            
        case 'm'
            
            nb_errorWindow('To save a graph to a MATLAB script (*.m) is not yet supported.');
            return
            
        case 'fig'
            
            if isa(gui.plotter,'nb_graph_adv')
                fig = get(gui.plotter.plotter(1),'figureHandle');
            else
                fig = get(gui.plotter,'figureHandle');
            end
            matFig    = fig.figureHandle;
            menuObj   = findobj(matFig,'type','uimenu');
            resizeFcn = get(matFig,'resizeFcn');
            set(menuObj,'visible','off')
            set(matFig,'resizeFcn','','resize','off')
            saveas(matFig,saveName,'fig');
            set(menuObj,'visible','on')
            set(matFig,'resizeFcn',resizeFcn,'resize','on')
            
        otherwise
            nb_errorWindow(['Unsupported extension ' newExt 'provided.']);
            return
    end

    % Revert things
    %--------------------------------------------------------------
    if ~(strcmpi(newExt,'mat') || strcmpi(newExt,'m') || strcmpi(newExt,'fig'))
        drawnow();
        set(matFig,'units',unitF,'position',posF);
        if isa(gui.plotter,'nb_graph_adv')
            for ii = 1:length(gui.plotter.plotter)
                gui.plotter.plotter(ii).axesScaleLineWidth = false;
                gui.plotter.plotter(ii).axesScaleFactor    = [];
                gui.plotter.plotter(ii).graph();
            end
        end
        
    end
    
    % We will here create a PDF in A4 portrait with the graph in the
    % correct rotation
    if isvalid(gui.rb4)
        
        if get(gui.rb4,'value') && strcmpi(newExt,'pdf')
            try
                portraitPDF(filename)
            catch Err
                nb_errorWindow('Could not write the PDF in portrait view.',Err);
            end
        end
        
    end

    if strcmpi(newExt,'emf') && forPPT 
       % Convert back to old positions
       if isa(gui.plotter,'nb_graph_adv')
            gui.plotter.set('figureTitleNor' ,oldNor);
            gui.plotter.set('figureTitleEng' ,oldEng);
            set(gui.plotter.plotter,'position',oldPos);
            setSpecial(gui.plotter.plotter,'defaultFigureNumbering',oldDefaultFigureNumbering);
            graph(gui.plotter.plotter);
       else
            set(gui.plotter,'position',oldPos);
            graph(gui.plotter);
        end
    end

    % Close window
    %--------------------------------------------------------------
    delete(gui.figureHandle);

end

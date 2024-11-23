function nb_saveas(fig,saveName,format,varargin)
% Syntax:
%
% nb_saveas(gcf,saveName)
% nb_saveas(fig,saveName,format)
% nb_saveas(fig,saveName,format,'-noflip')
% nb_saveas(fig,saveName,'pdf','-nocrop') % Only for pdf and jpg
% nb_saveas(fig,saveName,'pdf','-append') % Only for pdf
%
% Description:
%
% Saves the provided figureHandle to the provided file format.
% 
% Uses the export_fig package and Ghostscript.
%
% Input:
% 
% - fig      : Handle to the current figure
%
% - saveName : The save file name. With or without extension.
%
% - format   : The saved file format:
%
%              - 'pdf'  : PDF file using the export_fig
%              - 'emf'  : EMF using print
%              - 'eps'  : EPS using print
%              - 'png'  : PNG file using the export_fig
%              - 'dpng' : PNG using print
%              - 'svg'  : 
%              - 'jpg'  : JPG file using the export_fig
%              - 'djpg' : JPG using print
%
% Optional input:
%
% - '-noflip'     : Not flip the saved output. 
%
% - '-nocrop'     : Don't crop pdf figures.
%
% - '-append'     : Append to existing pdf.
%
% - '-a4portrait' : A4 portrait format. Will overrule the other optional 
%                   inputs.
% 
% Output:
% 
% - The figure saved to the wanted file format.
%
% Examples:
%
% See also:
% saveas
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the MATLAB figure handle
    if isa(fig,'nb_figure')
        fig = fig.figureHandle;
    elseif isa(fig,'nb_graphPanel')
        fig = fig.figureHandle;
    elseif ~strcmpi(get(fig,'type'),'figure')
        error([mfilename ':: The input fig must be a MATLAB figure handle, an nb_figure object or an nb_graphPanel object.'])
    end   
        
    % Find the saved file format.
    %--------------------------------------------------------------
    if nargin < 3
        format = 'pdf';
    end
        
    [p,f,~]  = fileparts(saveName);
    saveName = fullfile(p,f);
            
    switch lower(format)

        case 'pdf'

            inputs = {'-pdf','-painters','-transparent'};

            if ~any(strcmpi('-a4portrait',varargin))  
                if any(strcmpi('-nocrop',varargin))
                    inputs = [inputs, '-nocrop'];
                else
                    figObj = get(fig,'userData');
                    if isa(figObj,'nb_figure')
                        % [left,bottom,right-left,top-bottom]
                        extent = getInnerExtent(figObj,'normalized');
                        % [top,right,bottom,left]
                        inputs = [inputs, {['-c[',...
                            num2str(extent(1)),',',...
                            num2str(extent(2)),',',...
                            num2str(extent(1) + extent(3)),',',...
                            num2str(extent(2) + extent(4)),']']}];
                    end                  
                end
            end
            
            if any(strcmpi('-append',varargin))
                
                ind = strfind(saveName,'\');
                if isempty(ind)
                    testName = [pwd '\' saveName '.pdf'];
                else
                    testName = [saveName '.pdf'];
                end

                if exist(testName,'file') == 2
                    if ~any(strcmpi('-a4portrait',varargin))
                        inputs = [inputs, '-append'];
                    end
                end

            end
             
        case 'png'

            inputs = {'-png','-opengl','-transparent'};

            if any(strcmpi('-nocrop',varargin))
                inputs = [inputs, '-nocrop'];
            end

        case 'jpg'

            inputs = {'-jpg','-opengl','-transparent'};

            if any(strcmpi('-nocrop',varargin))
                inputs = [inputs, '-nocrop'];
            end
            
    end

    % Flip the printed output, if not '-noflip' is given
    %--------------------------------------------------------------
    if strcmpi(format,'pdf')
        if any(strcmpi('-noflip',varargin))
            inputs = [inputs, '-noflip'];
        end
    else
        if any(strcmpi('-noflip',varargin)) % This is correct!!!
            set(fig,'PaperSize',fliplr(get(fig,'PaperSize')));
        end
    end
    
    % Print the figure
    %--------------------------------------------------------------
    switch lower(format)

        case 'pdf'

            % We will here create a PDF in A4 portrait with the graph in 
            % the correct rotation
            if any(strcmpi('-a4portrait',varargin))
                
                if any(strcmpi('-append',varargin)) && exist(testName,'file') == 2
                    export_fig(fig,[saveName '_temp'],inputs{:});
                    portraitPDF([saveName '_temp.pdf'],[saveName '.pdf']) % Here we append to a existing pdf file
                    dos(['del ' saveName '_temp.pdf']);
                else
                    export_fig(fig,saveName,inputs{:});
                    portraitPDF([saveName '.pdf'])
                end
                
            else
                export_fig(fig,saveName,inputs{:});
            end
            
        case 'svg'

            set(fig,...
                'paperPositionMode',    'auto',...
                'renderer',             'painters', ...
                'invertHardcopy',       'off');
            plot2svg([saveName '.svg'],fig)

        case 'emf'

            set(fig,...
                'paperPositionMode',    'auto',...
                'renderer',             'painters', ...
                'invertHardcopy',       'off');
            print(fig,'-dmeta',[saveName '.emf'])

        case 'eps'

            set(fig,...
                'paperPositionMode',    'auto',...
                'renderer',             'painters', ...
                'invertHardcopy',       'off');
            print(fig,'-depsc','-tiff','-r300',[saveName '.eps'])

        case 'jpg'

            export_fig(fig,saveName,inputs{:});

        case 'djpg'
            
            set(fig,...
                'paperPositionMode',    'auto',...
                'renderer',             'openGL', ...
                'invertHardcopy',       'off');
            print(fig,'-djpeg90',[saveName '.jpg'])
            
        case 'png'

%             set(fig,...
%                 'paperPositionMode',    'auto',...
%                 'renderer',             'painters', ...
%                 'invertHardcopy',       'off');
%             print(fig,'-depsc','-tiff','-r300','temp.eps')
%             system(['gswin64c -o -q -sDEVICE=png256 -dEPSCrop -r300 -o' saveName '.png temp.eps']);
%             dos('del temp.eps');
            export_fig(fig,saveName,inputs{:});
            
        case 'dpng'
            
            set(fig,...
                'paperPositionMode',    'auto',...
                'renderer',             'openGL', ...
                'invertHardcopy',       'off');
            print(fig,'-dpng',[saveName '.png']);
            
        otherwise

            error([mfilename ':: Unsupported file format ' format]);

    end
    
end

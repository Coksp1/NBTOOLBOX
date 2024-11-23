function [code,numOfGraphs] = getCode(obj,frameTitle,frameSubTitle,footer,source,pageNumber,theme)
% Syntax:
% 
% [code,numOfGraphs] = getCode(obj,frameTitle,frameSubTitle,...
%                              footer,source,pageNumber,theme)
% 
% Description:
% 
% Get the latex code when including a graph in a slide object 
% produced by an object of class nb_graph_ts.
%
% This method is called from the nb_Slide class, when making a 
% beamer slide in latex.
% 
% Input:
% 
% - obj           : An object of class nb_graph_ts
% 
% - frameTitle    : A string with the frame title of the slide.
% 
% - frameSubTitle : A string with the frame subtitle of the slide.
% 
% - footer        : A cellstr with the footers of the slide
%  
% - source        : A cellstr with the sources of the slide
% 
% - pageNumber    : Give 1 if the page number should be included.
% 
% - theme         : The beamer theme used. Default is '' (use default 
%                   beamer theme). 
%
% Output:
% 
% - code          : The latex code as a char.
% 
% - numOfGraphs   : The number of graphs produced by the input 
%                   object of class nb_graph_ts. As an integer.
%     
% Examples:
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 7
        theme = '';
    end

    numOfGraphs = obj.numberOfGraphs;
    format      = obj.fileFormat;
    fnames      = fieldnames(obj.GraphStruct);

    code = '\r\n';
    for ii = 1:numOfGraphs

        if strcmpi(obj.graphMethod,'graphinfostruct') && obj.subPlotSpecial
            
            if obj.subPlotSize(1) == 1
                code = char(code,'\\begin{frame}[c]\r\n');
            else
                code = char(code,'\\begin{frame}[t]\r\n');
            end
            
        elseif strcmpi(obj.graphMethod,'graphsubplots') && obj.subPlotSpecial
            
            if obj.subPlotSize(2) == 2 && obj.subPlotSize(1) == 1 || obj.subPlotSize(2) == 3
                code = char(code,'\\begin{frame}[c]\r\n');
            else
                code = char(code,'\\begin{frame}[t]\r\n');
            end
            
        else
            code = char(code,'\\begin{frame}[t]\r\n');
        end
        
        code = char(code,'\r\n');

        if ~isempty(frameTitle)
            frameTitle = nb_Presentation.strRepNorwegian(frameTitle);
            code       = char(code,['  \\frametitle{' frameTitle '}\r\n']);
        end

        code = char(code,'\r\n');

        if ~isempty(frameSubTitle)
            frameSubTitle = nb_Presentation.strRepNorwegian(frameSubTitle);
            code          = char(code,['  \\framesubtitle{' frameSubTitle '}\r\n']);
        end

        if strcmpi(theme,'NorgesBankNew')
        
            % Calculate the number of rows of the text at the
            % bottom of the page
            numFooters     = length(footer);
            numSources     = length(source);
            numOfTextLines = max(numFooters,numSources);

            % Correct the figure height given the number of text lines
            % at the bottom of the figure
            switch numOfTextLines  
                case {0,1}
                    vSkip = 0;
                case 2
                    vSkip = 8;
                case 3
                    vSkip = 16;
                otherwise
                    vSkip = 24;
            end

            % Latex code for calculation of height and width of the
            % included figure
            code   = char(code,'\r\n');
            code   = char(code,'\\calculatespace\r\n');
            code   = char(code,'\r\n');
            code   = char(code,['\\advance\\contentheight by-' int2str(vSkip) 'pt\r\n']);
            code   = char(code,'\r\n');
            width  = '\\contentwidth';
            height = '\\contentheight';
        else
            width  = '\\textwidth';
            height = '0.8\\textheight';
        end

        % Include the figure
        if strcmpi(theme,'NorgesBankNew')
            if strcmpi(obj.graphMethod,'graphinfostruct') && obj.subPlotSpecial
                if size(obj.GraphStruct.(fnames{ii}),1) > 1
                    if obj.subPlotSize(1) == 1
                        height = ['0.6', height]; %#ok<AGROW>
                    else
                        width = ['0.6', width]; %#ok<AGROW>
                    end
                end
            elseif strcmpi(obj.graphMethod,'graphsubplots') && obj.subPlotSpecial
                if obj.subPlotSize(1) == 2 ||  obj.subPlotSize(2) == 2 || obj.subPlotSize(2) == 3               
                    if obj.subPlotSize(1) == 1
                        height = ['0.6', height]; %#ok<AGROW>
                    else
                        width = ['0.6', width]; %#ok<AGROW>
                    end
                end
            end  
        end
        
        code = char(code,['   \\centerline{ \\includegraphics<1>[width=' width ',height=' height ']{' obj.saveName '_' int2str(ii) '.' format '}}\r\n']);
        
        if strcmpi(theme,'NorgesBankNew')
        
            % Include the footers
            if not(isempty(footer) && isempty(source))

                code = char(code,'\r\n');

                % Code for the footer text
                for jj = 1:numFooters

                    switch jj
                        case 1
                            code = char(code,['   \\footlineleft{\\tiny ' footer{end} '}\r\n']);
                        case 2
                            code = char(code,['   \\footlineleftSecond{\\tiny ' footer{numFooters - 1} '}\r\n']);
                        case 3
                            code = char(code,['   \\footlineleftThird{\\tiny ' footer{numFooters - 2} '}\r\n']);
                        case 4
                            code = char(code,['   \\footlineleftFourth{\\tiny ' footer{numFooters - 3} '}\r\n']);
                        otherwise
                            error([mfilename ':: Too many source lines are given ' int2str(numFooters) ', but 4 is max.'])
                    end

                end

                % Code for the source text
                for jj = 1:numSources

                    switch jj
                        case 1
                            code = char(code,['  \\footlineright{\\tiny ' source{end} '}\r\n']);
                        case 2
                            code = char(code,['  \\footlinerightSecond{\\tiny ' source{numSources - 1} '}\r\n']);
                        case 3
                            code = char(code,['  \\footlinerightThird{\\tiny ' source{numSources - 2} '}\r\n']);
                        case 4
                            code = char(code,['  \\footlinerightFourth{\\tiny ' source{numSources - 3} '}\r\n']);
                        otherwise
                            error([mfilename ':: Too many source lines are given ' int2str(numSources) ', but 4 is max.'])
                    end

                end

            end

            if pageNumber
                code = char(code,'\r\n');
                code = char(code,'\\pageNumber{\\footnotesize \\color{nbblue}{\\thepage}}\r\n');
            end
            
        end

        code = char(code,'\r\n');
        code = char(code,'\\end{frame}\r\n');
        code = char(code,'\r\n');

    end

end

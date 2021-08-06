function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Sets the properties of the nb_graph_adv object.
% 
% See the documentation of the nb_graph_adv class for more on the
% different properties.
% 
% Input:
% 
% - obj      : An object of class nb_graph_adv
% 
% - varargin : 'propertyName',propertyValue,...
%
% Output:
% 
% - obj      : The input object with the updated properties.
%
% Examples:
% 
% set(obj,'propertyName',propertyValue);
% obj.set('propertyName',propertyValue,...)
% obj = obj.set('footerfontsize',14);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    for jj = 1:2:size(varargin,2)

        propertyName  = varargin{jj};
        propertyValue = varargin{jj + 1};

        if ischar(propertyName)

            switch lower(propertyName)
                
                case 'a4portrait'
                    
                    if ismember(propertyValue,[0,1])
                        obj.a4Portrait = propertyValue;
                    else
                        error([mfilename ':: The input after the ''flip'' property must be an integer, '...
                                         'either 1 or 0.'])
                    end 
                     
                case 'chapter'
                    
                    if isscalar(propertyValue) && isnumeric(propertyValue)
                        obj.chapter = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar.'])
                    end
                
                case 'counter'
                    
                    if isscalar(propertyValue) && isnumeric(propertyValue)
                        obj.counter = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar.'])
                    end
                    
                case 'defaultfigurenumbering'
                    
                    if nb_isScalarLogical(propertyValue)
                        obj.defaultFigureNumbering = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar logical (true/false).'])
                    end    
                    
                case 'excelfootereng'

                    if ischar(propertyValue)
                        obj.excelFooterEng = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.excelFooterEng = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end
                    
                case 'excelfooternor'

                    if ischar(propertyValue)
                        obj.excelFooterNor = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.excelFooterNor = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end 
                      
                case 'flip'

                    if ismember(propertyValue,[0,1])
                        obj.flip = propertyValue;
                    else
                        error([mfilename ':: The input after the ''flip'' property must be an integer, '...
                                         'either 1 or 0.'])
                    end       
                    
                case 'fontname'

                    if ischar(propertyValue)
                        obj.fontName = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    fig  = get(obj.plotter(1),'figTitleObjectNor'); 
                    if ~isempty(fig)
                        fig.fontName = obj.fontName;     
                        obj.plotter(1).setSpecial('figTitleObjectNor',fig);
                    end
                    
                    fig = get(obj.plotter(1),'figTitleObjectEng'); 
                    if ~isempty(fig)
                        fig.fontName = obj.fontName;     
                        obj.plotter(1).setSpecial('figTitleObjectEng',fig);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectNor');
                    if ~isempty(foo)
                        foo.fontName = obj.fontName;     
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng'); 
                    if ~isempty(foo)
                        foo.fontName = obj.fontName;     
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'fontunits'
                    
                    if ischar(propertyValue)
                        oldFontSize   = obj.fontUnits;
                        obj.fontUnits = propertyValue;
                        setFontSize(obj,oldFontSize);
                    else
                        error([mfilename ':: The input after the ''fontUnits'' property must be a string.'])
                    end 
                    
                case 'footereng'

                    if ischar(propertyValue)
                        obj.footerEng = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.footerEng = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng');
                    if ~isempty(foo)
                        foo.string = char(obj.footerEng); 
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'footernor'

                    if ischar(propertyValue)
                        obj.footerNor = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.footerNor = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end 
                    
                    foo = get(obj.plotter(1),'footerObjectNor');
                    if ~isempty(foo)
                        foo.string = char(obj.footerNor); 
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                case 'footeralignment'

                    if ischar(propertyValue)
                        obj.footerAlignment = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectNor');
                    if ~isempty(foo)
                        foo.alignment = obj.footerAlignment;  
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng');
                    if ~isempty(foo)
                        foo.alignment = obj.footerAlignment;  
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'footerfontsize'

                    if isscalar(propertyValue)
                        obj.footerFontSize = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar.'])
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectNor');
                    if ~isempty(foo)
                        foo.fontSize = obj.footerFontSize; 
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng');  
                    if ~isempty(foo)
                        foo.fontSize = obj.footerFontSize; 
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'footerfontweight'

                    if ischar(propertyValue)
                        obj.footerFontWeight = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectNor');
                    if ~isempty(foo)
                        foo.fontWeight = obj.footerFontWeight;    
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng');
                    if ~isempty(foo)
                        foo.fontWeight = obj.footerFontWeight;    
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'footerinterpreter'

                    if ischar(propertyValue)
                        obj.footerInterpreter = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end  
                    
                    foo = get(obj.plotter(1),'footerObjectNor'); 
                    if ~isempty(foo)
                        foo.interpreter = obj.footerInterpreter;                
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng'); 
                    if ~isempty(foo)
                        foo.interpreter = obj.footerInterpreter;                
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'footerplacement'

                    if ischar(propertyValue)
                        obj.footerPlacement = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectNor'); 
                    if ~isempty(foo)
                        foo.placement = obj.footerPlacement; 
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng');  
                    if ~isempty(foo)
                        foo.placement = obj.footerPlacement; 
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end
                    
                case 'footerwrapping'

                    if nb_isScalarLogical(propertyValue)
                        obj.footerWrapping = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar logical.'])
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectNor'); 
                    if ~isempty(foo)
                        foo.wrap = obj.footerWrapping; 
                        obj.plotter(1).setSpecial('footerObjectNor',foo);
                    end
                    
                    foo = get(obj.plotter(1),'footerObjectEng');  
                    if ~isempty(foo)
                        foo.wrap = obj.footerWrapping; 
                        obj.plotter(1).setSpecial('footerObjectEng',foo);
                    end    
                    
                case 'force'
                    
                    error([mfilename ':: The ' propertyName ' has been removed.'])

                case 'forecastdate'

                    if ischar(propertyName)
                        obj.forecastDate = cellstr(propertyValue);
                    elseif iscellstr(propertyName)
                        obj.forecastDate = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char or a cellstr.'])
                    end

                case 'figurenameeng'

                    if ischar(propertyValue)
                        obj.figureNameEng = propertyValue;
                    elseif iscellstr(propertyValue)
                        obj.figureNameEng = char(propertyValue);    
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char.'])
                    end

                case 'figurenamenor'

                    if ischar(propertyValue)
                        obj.figureNameNor = propertyValue;
                    elseif iscellstr(propertyValue)
                        obj.figureNameNor = char(propertyValue);
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or a cellstr.'])
                    end    

                case 'figuretitleeng'

                    if ischar(propertyValue)
                        obj.figureTitleEng = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.figureTitleEng = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end  
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng'); 
                    if ~isempty(figTit)
                        figTit.string = char(obj.figureTitleEng);
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end
                    
                case 'figuretitlenor'
                    
                    if ischar(propertyValue)
                        obj.figureTitleNor = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.figureTitleNor = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end  
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor'); 
                    if ~isempty(figTit)
                        figTit.string = char(obj.figureTitleNor);
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                case 'figuretitlealignment'

                    if ischar(propertyValue)
                        obj.figureTitleAlignment = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor');
                    if ~isempty(figTit)
                        figTit.alignment = obj.figureTitleAlignment;  
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng');
                    if ~isempty(figTit)
                        figTit.alignment = obj.figureTitleAlignment;  
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end

                case 'figuretitlefontsize'

                    if isscalar(propertyValue)
                        obj.figureTitleFontSize = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar.'])
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor');
                    if ~isempty(figTit)
                        figTit.fontSize = obj.figureTitleFontSize; 
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng'); 
                    if ~isempty(figTit)
                        figTit.fontSize = obj.figureTitleFontSize; 
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end
                    
                case 'figuretitlefontweight'

                    if ischar(propertyValue)
                        obj.figureTitleFontWeight = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor');
                    if ~isempty(figTit)
                        figTit.fontWeight = obj.figureTitleFontWeight;    
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng');
                    if ~isempty(figTit)
                        figTit.fontWeight = obj.figureTitleFontWeight;    
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end

                case 'figuretitleinterpreter'

                    if ischar(propertyValue)
                        obj.figureTitleInterpreter = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end 
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor'); 
                    if ~isempty(figTit)
                        figTit.interpreter = obj.figureTitleInterpreter;          
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng'); 
                    if ~isempty(figTit)
                        figTit.interpreter = obj.figureTitleInterpreter;          
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end
                    
                case 'figuretitleplacement'

                    if ischar(propertyValue)
                        obj.figureTitlePlacement = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor'); 
                    if ~isempty(figTit)
                        figTit.placement = obj.figureTitlePlacement; 
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng'); 
                    if ~isempty(figTit)
                        figTit.placement = obj.figureTitlePlacement; 
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end
                    
                case 'figuretitlewrapping'

                    if nb_isScalarLogical(propertyValue)
                        obj.figureTitleWrapping = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar logical.'])
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectNor'); 
                    if ~isempty(figTit)
                        figTit.wrap = obj.figureTitleWrapping; 
                        obj.plotter(1).setSpecial('figTitleObjectNor',figTit);
                    end
                    
                    figTit = get(obj.plotter(1),'figTitleObjectEng');  
                    if ~isempty(figTit)
                        figTit.wrap = obj.figureTitleWrapping; 
                        obj.plotter(1).setSpecial('figTitleObjectEng',figTit);
                    end     
                    
                case 'jump'
                    
                    if isscalar(propertyValue)
                        if propertyValue <= 0
                            error([mfilename ':: The ' propertyName ' property must be a positiv scalar and not 0..'])
                        else
                            obj.jump = propertyValue;
                        end
                    else
                        error([mfilename ':: The ' propertyName ' property must be a positiv scalar.'])
                    end

                case 'legendseng'

                    if iscellstr(propertyValue)
                        obj.legendsEng = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a cellstr.'])
                    end

                case 'letter'

                    if isscalar(propertyValue)
                        obj.letter = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a number. Either 1 or 0.'])
                    end
                    
                case 'letterrestart'

                    if isscalar(propertyValue)
                        obj.letterRestart = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a number. Either 1 or 0.'])
                    end    
                    
                case 'localvariables'
                    
                    if isa(propertyValue,'nb_struct')
                        obj.localVariables         = propertyValue;
                        for ii = 1:size(obj.plotter,2)
                            obj.plotter(ii).localVariables = propertyValue;
                        end
                    else
                        error([mfilename ':: The ' propertyName ' property must be a set to a nb_struct.'])
                    end
                    
                case 'number'

                    if isscalar(propertyValue)
                        obj.number = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a number.'])
                    end    

                case 'remove'

                    if iscellstr(propertyValue)
                        obj.remove = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a cellstr.'])
                    end
                    
                case 'savename'

                    if ischar(propertyValue)
                        obj.saveName = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a char.'])
                    end
                    
                case 'tooltipeng'

                    if ischar(propertyValue)
                        obj.tooltipEng = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.tooltipEng = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end                        
                    
                case 'tooltipnor'

                    if ischar(propertyValue)
                        obj.tooltipNor = cellstr(propertyValue);
                    elseif iscellstr(propertyValue)
                        obj.tooltipNor = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be either a char or cellstr.'])
                    end  
                    
                case 'tooltipwrapping'

                    if nb_isScalarLogical(propertyValue)
                        obj.tooltipWrapping = propertyValue;
                    else
                        error([mfilename ':: The ' propertyName ' property must be a scalar logical.'])
                    end    
                    
                case 'userdata'
                    
                    obj.userData = propertyValue;    
                    
                otherwise

                    error([mfilename ':: The class nb_graph_adv has no property ''' propertyName ''' or you have no access to set it.'])

            end

        end

    end
    
end

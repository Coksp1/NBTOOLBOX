function set(obj,varargin)
% Syntax:
% 
% set(obj,varargin)
% 
% Description:
% 
% Set properties of the nb_graph_subplot class.
%
% See documentation NB Toolbox or type help('nb_graph_subplot') for
% more on the properties of the class.
% 
% Input:
% 
% - obj      : An object of class nb_graph_subplot
% 
% - varargin : 'propertyName',propertyValue,...
%
% Output:
%
% The input objects properties set to their new value.
% 
% Examples:
% 
% obj.set('subPLotSize',[2,2]);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if size(varargin,1) && iscell(varargin{1})
        % Makes it possible to give options directly through a cell
        varargin = varargin{1};
    end

    for jj = 1:2:size(varargin,2)

        propertyName  = varargin{jj};
        propertyValue = varargin{jj + 1};

        if ischar(propertyName)

            switch lower(propertyName)
                
                case 'a4portrait'
                    
                    if ismember(propertyValue,[0,1])
                        obj.a4Portrait = propertyValue;
                    else
                        error([mfilename ':: The input after the ''a4Portrait'' property must be an integer, '...
                                         'either 1 or 0.'])
                    end 
                    
                case 'axesscalelinewidth'

                    if ~isscalar(propertyValue)
                        error([mfilename ':: The input after ''axesScaleLineWidth'' must be either true or false.']);
                    end
                    if ismember(propertyValue,[0,1])
                        obj.axesScaleLineWidth = propertyValue;
                    else
                        error([mfilename ':: The input after ''axesScaleLineWidth'' must be either true or false.']);
                    end      
                
                case 'crop'

                    if isscalar(propertyValue)
                        obj.crop = propertyValue;  
                    else
                        error([mfilename ':: The input after ''crop'' must be an integer. Eihter 1 (crop) or 0 (no crop).']);
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
                    
                case 'figureposition'
                    
                    if isnumeric(propertyValue)
                        obj.figurePosition = propertyValue;
                    else
                        error([mfilename ':: The input after the ''figurePosition'' input must be a 1x4 double.'])
                    end 
                    
                case 'figurehandle'
                    
                    if isa(propertyValue,'nb_figure')
                        obj.figureHandle            = propertyValue;
                        obj.manuallySetFigureHandle = 1;
                    else
                        error([mfilename ':: The input after the ''figureHandle'' input must be an nb_figure or an nb_graphPanel object.'])
                    end 
                    
                case 'fileformat'

                    if ischar(propertyValue)
                        obj.fileFormat = propertyValue;
                    else
                        error([mfilename ':: The input after the ''fileFormat'' property must be a string with the format name.'])
                    end
                    
                case 'flip'

                    if isscalar(propertyValue)
                        obj.flip = propertyValue;
                    else
                        error([mfilename ':: The input after the ''flip'' property must be an integer, '...
                                         'either 1 or 0.'])
                    end    
                    
                case 'graphobjects'
                    
                    if iscell(graphObjects)
                        
                        ind1 = cellfun('isclass',propertyValue,'nb_graph_ts');
                        ind2 = cellfun('isclass',propertyValue,'nb_graph_cs');
                        ind  = ind1 + ind2;
                        if any(~ind)
                            error([mfilename ':: The property ' propertyName ' must be given as a cell of nb_graph_ts and/or nb_graph_cs objects.'])
                        else
                            obj.graphObjects = propertyValue;
                        end
                        
                    else
                        error([mfilename ':: The property ' propertyName ' must be given as a cell of nb_graph_ts and/or nb_graph_cs objects.'])
                    end
                    
                case 'graphstyle'

                    if ischar(propertyValue)
                        obj.graphStyle = propertyValue;
                    else
                        error([mfilename ':: The input after ''graphStyle'' must be a string. Give ''mpr'' if you want the standard MPR looking graph.']);
                    end 
                    
                    setDefaultSettings(obj);    
                        
                case 'language'

                    if ischar(propertyValue)
                        obj.language = lower(propertyValue);
                    else
                        error([mfilename ':: The input after the ''language'' property must be a string. ''english'' or ''norsk''.'])
                    end     
                    
                case 'manualaxesposition'
                    
                    if isscalar(propertyValue) && islogical(propertyValue)
                        obj.manualAxesPosition = propertyValue;
                    else
                        error([mfilename ':: The input after the ''manualAxesPosition'' property must either be set to true or false.'])
                    end  
                    
                case 'pdfbook'

                    if isscalar(propertyValue)
                        obj.pdfBook = propertyValue;
                    else
                        error([mfilename ':: The input after the ''pdfBook'' property must be an integer. Either 1 (save all pdf in one pdf) or 0 (single pdfs). '...
                            'Default is 0.'])
                    end  
                    
                case 'plotaspectratio'

                    if ischar(propertyValue) || isempty(propertyValue)
                        obj.plotAspectRatio = propertyValue;
                    else
                        error([mfilename ':: The input after the ''plotAspectRatio'' property must be a scalar.'])
                    end      
    
                case 'savename'

                    if ischar(propertyValue)
                        obj.saveName = propertyValue;
                    else
                        error([mfilename ':: The input after the ''saveName'' property must be a string with the save name of the figure file.'])
                    end  
                    
                case 'scale'

                    if isscalar(propertyValue)
                        obj.scale = propertyValue;
                    else
                       error([mfilename ':: The input after the ''scale'' property must be set to a number between 0 or 1.']) 
                    end    
                    
                case 'shading'

                    if ischar(propertyValue)
                        obj.shading = lower(propertyValue);
                    else
                        error([mfilename ':: The input after the ''shading'' property must be a string with the color of shading.'])
                    end    
                    
                case 'subplotsize'

                    if isnumeric(propertyValue)
                        obj.subPlotSize = propertyValue;
                    else
                       error([mfilename ':: The input after the ''subPlotSize'' property must be a 1 x 2 double vector; '...
                                        '(horizontal size of the subplots, vertical size of the subplot).']) 
                    end

                case 'subplotspecial'

                    if isscalar(propertyValue)
                        obj.subPlotSpecial = propertyValue;
                    else
                       error([mfilename ':: The input after the ''subPlotSpecial'' property must set to a scalar. Either 1 or 0.']) 
                    end
                    
                case 'userdata'
                    
                    obj.userData = propertyValue;       
                   
                otherwise

                    error([mfilename ':: The class nb_graph_ts has no property ''' propertyName ''' or you have no access to set it.'])
            end

        end
        
    end

end

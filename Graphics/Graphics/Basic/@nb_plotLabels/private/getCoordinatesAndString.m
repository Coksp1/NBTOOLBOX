function [xCor,yCor,string] = getCoordinatesAndString(obj,child,xx,yy,format)

    % Get data point
    if isa(child,'nb_plotComb')
        type = child.types{yy};
        switch lower(type)
            case 'area'
                cl = 'nb_area';
            case {'grouped','stacked','dec'}
                cl = 'nb_bar';
            otherwise
                cl = type;
        end
    else
        cl = class(child);
    end
    
    side = 'left';
    try side = child.side; catch; end %#ok<CTCH>
        
    if any(strcmpi(cl,{'nb_bar','nb_hbar'}))
        
        if size(child.xData,1) == 1 || size(child.xData,2) == 1
            xCor = child.xData(xx);
        else
            xCor = child.xData(xx,yy);
        end
        
        grouped = false;
        if isa(child,'nb_plotComb')
            if strcmpi(type,'grouped')
                barWidth = child.barWidth;
                barChild = child.children(cellfun(@(x)isa(x,'nb_bar'),child.children));
                n        = size(barChild{1}.yData,2);
                indyy    = strcmpi('grouped',child.types);
                indyy    = sum(indyy(1:yy));
                xCor     = xCor - barWidth/2 + barWidth/n/2 + barWidth*(indyy-1)/n;
                grouped  = true;
            end
        else
            if strcmpi(child.style,'grouped')
                barWidth = child.barWidth;
                n        = size(child.yData,2);
                xCor     = xCor - barWidth/2 + barWidth/n/2 + barWidth*(yy-1)/n;
                grouped  = true;
            end
        end
        
        yData = child.yData;
        if ~grouped
            if isa(child,'nb_plotComb')
                ind   = strcmpi('stacked',child.types);
                yData = yData(:,ind);
                indyy = sum(ind(1:yy));
            else
                indyy = yy;
            end
            if isnan(yData(xx,indyy))
                yDat = nan;
            elseif yData(xx,indyy) < 0
                yData = yData(xx,1:indyy);
                yData = yData(yData < 0);
                yDat  = cumsum(yData,2);
                yDat  = yDat(end);
            else
                yData = yData(xx,1:indyy);
                yData = yData(yData >= 0);
                yDat  = cumsum(yData,2);
                yDat  = yDat(end);
            end
        else
            yDat = yData(xx,yy);
        end
        
        if ~isfield(format,'position')
            format.position = [];
        end
        if ~isempty(format.position)
            yCor = format.position;
        else
            switch lower(format.location)
                case 'top'
                    yCor = yDat;
                case 'bottom'
                    yCor = yDat - child.yData(xx,yy);
                otherwise
                    yCor = yDat - child.yData(xx,yy)/2;
                    format.location = 'halfway';
            end
        end
        
        if ~strcmpi(format.valueType, 'cumsum') && ~grouped
            yDat = child.yData(xx,yy);
        end
        
        if isa(child,'nb_hbar') 
            % Need to transpose the coordinates in this case!
            yCorT = xCor;
            xCor  = yCor;
            yCor  = yCorT;
        end
        
    elseif strcmpi(cl,'nb_area')
        
        if size(child.xData,1) == 1 || size(child.xData,2) == 1
            xCor = child.xData(xx);
        else
            xCor = child.xData(xx,yy);
        end
        
        yData = child.yData;
        if isa(child,'nb_plotComb')
            ind   = strcmpi('area',child.types);
            yData = yData(:,ind);
        end
        
        if yData(xx,yy) < 0
            yData = yData(xx,1:yy);
            yData = yData(yData < 0);
            yDat  = cumsum(yData,2);
            yDat  = yDat(end);
        else
            yData = yData(xx,1:yy);
            yData = yData(yData >= 0);
            yDat  = cumsum(yData,2);
            yDat  = yDat(end);
        end
        
        if ~isempty(format.position)
            yCor = format.position;
        else
            switch lower(format.location)
                case 'top'
                    yCor = yDat;
                case 'bottom'
                    yCor = yDat - child.yData(xx,yy);
                otherwise
                    yCor = yDat - child.yData(xx,yy)/2;
                    format.location = 'halfway';
            end
        end
        
        if ~strcmpi(format.valueType, 'cumsum')
            yDat = child.yData(xx,yy);
        end
        
    elseif strcmpi(cl, 'nb_pie')

        % Text position
        labelDistance = 0.2;
        [xCor, yCor, angle] = child.getSlicePosition(yy, 0.5, labelDistance);

%         if angle < pi/4
%             hAlignment = 'left';
%             vAlignment = 'middle';
%         elseif angle < pi*3/4
%             hAlignment = 'center';
%             vAlignment = 'bottom';
%         elseif angle < pi*5/4
%             hAlignment = 'right';
%             vAlignment = 'middle';
%         elseif angle < pi*7/4
%             hAlignment = 'center';
%             vAlignment = 'top';
%         else
%             hAlignment = 'left';
%             vAlignment = 'middle';
%         end
        
        % TODO: Set alignments
        
        % Value
        switch lower(format.valueType)
            case 'share'
                yDat = child.yData(yy) / sum(child.yData);
            otherwise
                yDat = child.yData(yy);
        end
        
    elseif strcmpi(cl, 'nb_donut')

        % Text position
        relRadius          = linspace(child.innerRadius,0,size(child.yData,1)+1);
        radius             = mean([relRadius(xx),relRadius(xx+1)]);
        [xCor, yCor, angle] = child.getSlicePosition(xx, yy, 0.5, radius);

%         if angle < pi/4
%             hAlignment = 'left';
%             vAlignment = 'middle';
%         elseif angle < pi*3/4
%             hAlignment = 'center';
%             vAlignment = 'bottom';
%         elseif angle < pi*5/4
%             hAlignment = 'right';
%             vAlignment = 'middle';
%         elseif angle < pi*7/4
%             hAlignment = 'center';
%             vAlignment = 'top';
%         else
%             hAlignment = 'left';
%             vAlignment = 'middle';
%         end
        
        % TODO: Set alignments
        
        % Value
        switch lower(format.valueType)
            case 'share'
                yDat = child.yData(xx,yy) / sum(child.yData(xx,:));
            otherwise
                yDat = child.yData(xx,yy);
        end    
        
    else
        
        if size(child.xData,1) == 1 || size(child.xData,2) == 1
            xCor = child.xData(xx);
        else
            xCor = child.xData(xx,yy);
        end
        yCor = child.yData(xx,yy);
        yDat = yCor;
        
    end
    
    % Get string of label
    if ~format.edited
        
        switch lower(format.textFormat)
            case '%'
                yDat = 100 * yDat;
        end
        
        switch format.decimals
            case 0
                regexp = '%0.0f';
            case 1
                regexp = '%0.1f';
            case 2
                regexp = '%0.2f';
            case 3
                regexp = '%0.3f';
            case 4 
                regexp = '%0.4f';
            otherwise
                regexp = '%0.4f';
        end

        string = num2str(yDat,regexp);
        if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
            string = strrep(string,'.',',');
        end
        
        if strcmpi(cl,'nb_scatter')
            stringX = num2str(xCor,regexp);
            if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                stringX = strrep(stringX,'.',',');
            end
            string = [stringX,';',string];
        end
        
        switch lower(format.textFormat)
            case '%'
                string = [string, ' %'];
            case 'kr'
                string = ['kr ' string];
            case '$'
                string = ['$ ' string];
        end
        
    else
        string = format.string;
    end

    % Convert to axes units
    pos    = obj.parent.position;
    xLim   = obj.parent.xLim;
    xScale = obj.parent.xScale;
    if strcmpi(side,'left')
        yLim   = obj.parent.yLim;
        yScale = obj.parent.yScale;
    else
        yLim   = obj.parent.yLimRight;
        yScale = obj.parent.yScaleRight;
    end
    
    xCor = nb_pos2pos(xCor,xLim,[pos(1),pos(1) + pos(3)],xScale,'normal');
    yCor = nb_pos2pos(yCor,yLim,[pos(2),pos(2) + pos(4)],yScale,'normal');
    
    switch format.location
        case 'right'
            xCor = xCor + format.space;
        case 'left'
            xCor = xCor - format.space;
        case {'above','bottom'}
            yCor = yCor + format.space;
        case {'below','top'}
            yCor = yCor - format.space;
    end
    
end

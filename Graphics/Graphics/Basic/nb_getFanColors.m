function cData = nb_getFanColors(cData,percentiles)
% Syntax:
%
% cData = nb_getFanColors(cData,percentiles)
%
% Description:
%
% Get fan colors
% 
% Input:
% 
% - cData       : A string with the base color to use. {'nb'} | 'yellow'
%                 | 'magenta' | 'cyan' | 'red' | 'green' | 'blue' |
%                 'grey' | 'white'
%       
% - percentiles : The percentiles as 1 x numberOfPercentiles double. E.g:
%                 [.3,.5,.7,.9] (Which is default)
% 
% Output:
% 
% - cData       : A numberOfPercentiles x 3 double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        percentiles = [.3,.5,.7,.9];
        if nargin < 1
            cData = 'nb';
        end
    end

    if isempty(cData)
                
        % Get the default color(s) ('nb')
        if size(percentiles,2) < 6
            nPerc = size(percentiles,2);
            cData = [50  125 178
                     78  150 193
                     123 185 212
                     176 220 241
                     210 235, 249
                     225 240, 255]/255;
            if nPerc > 4
                cData = cData(1:nPerc,:);
            elseif nPerc == 1
                cData = cData(2,:);    
            else
                %cData = cData(end-nPerc:end-1,:);
                cData = cData(end-nPerc+1:end,:);
            end
        else
            c_nb  = percentiles';
            cData = [0.05,0.05,.98;repmat([0, 0, 1],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[1,1,0];
        end

    else

        if isnumeric(cData)

            if size(cData,2) ~= 3
                error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
            elseif size(cData,1) ~= length(percentiles)
                error([mfilename ':: The ''cData'' property has not as many rows (' int2str(size(cData,1)) ') as the property ''percentile'' has length (' int2str(length(percentile)) ').'])
            end

        elseif ischar(cData)

            c_nb      = percentiles'; 
            colorName = cData;
            switch lower(colorName)

                case 'nb'
                
                    nPerc = size(percentiles,2);
                    if nPerc < 6
                        cData = [50  125 178
                                 78  150 193
                                 123 185 212
                                 176 220 241
                                 210 235, 249
                                 225 243, 252]/255;
                        if nPerc > 4
                            cData = cData(1:nPerc,:);
                        elseif nPerc == 1
                            cData = cData(4,:);
                        else
                            %cData = cData(end-nPerc:end-1,:); 
                            cData = cData(end-nPerc+1:end,:);
                        end
                    else
                        cData = [0.05,0.05,.98;repmat([0, 0, 1],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[1,1,0];
                    end

                case 'yellow'
                    cData = [.98,.98,0.05;repmat([1, 1, 0],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[0,0,1];
                case 'magenta'
                    cData = [.98,0.05,.98;repmat([1, 0, 1],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[0,1,0];
                case 'cyan'
                    cData = [0.05,.98,.98;repmat([0, 1, 1],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[1,0,0];
                case 'red'
                    cData = [0.98,0.05,0.05;repmat([1, 0, 0],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[0,1,1];
                case 'green'
                    cData = [0.05,0.98,0.05;repmat([0, 1, 0],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[1,0,1];
                case 'blue'
                    cData = [0.05,0.05,.98;repmat([0, 0, 1],size(c_nb,1) - 1,1)] + (c_nb - c_nb(1))*[1,1,0];
                case 'grey'
                    cData = c_nb*[1 1 1];
                case 'white'
                    cData = flipud(c_nb*[1 1 1]);
                otherwise
                    error([mfilename,':: Bad color specification'])
            end

        else
            error([mfilename ':: The property ''cData'' must be a double with the RGB colors or a string with '...
                             'the base color to use for the fan chart.'])
        end

    end

end

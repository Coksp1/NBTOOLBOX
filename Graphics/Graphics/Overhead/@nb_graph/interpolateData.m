function temp = interpolateData(data)
% Syntax:
%
% temp = nb_graph.interpolateData(data)
%
% Description:
%
% Interpolate missing values (NaN values)
%
% Input:
%
% - data : A double with the possibility of containing nan values 
% 
% Output:
%
% - temp : A double with the nan values interpolated.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    temp = data;

    for ii = 1:size(temp,2)

        tempIt = temp(:,ii);
        isNaN  = find(isnan(tempIt));

        if not(isempty(isNaN) || size(isNaN,1) == size(tempIt,1))

            % Do not interpolate leading nan values
            if isNaN(1) == 1

                next = tempIt(2);
                ll   = 2;
                while isnan(next)
                    next = tempIt(ll + 1);
                    ll   = ll + 1;
                end
                isNaN = isNaN(isNaN >= ll);

            end

            if isempty(isNaN)
                temp(:,ii) = tempIt;
            else

                % Do not interpolate trailing nan values
                if isNaN(end) == size(tempIt,1)

                    prev = tempIt(end - 1);
                    jj   = 1;
                    while isnan(prev)
                        prev = tempIt(end - (jj + 1));
                        jj   = jj + 1;
                    end
                    isNaN = isNaN(isNaN <= size(tempIt,1) - jj);

                end

                % Interpolate the rest
                num = size(isNaN,1);
                kk  = 1;
                while kk < num

                    dd = 1;
                    while isNaN(kk) + dd == isNaN(kk + dd) 

                        dd = dd + 1;

                        if kk + dd > num
                            break;
                        end

                    end

                    newValues = interp1(1:2,[tempIt(isNaN(kk) - 1) tempIt(isNaN(kk + dd - 1) + 1)],1:(1/(dd + 1)):2); 
                    tempIt(isNaN(kk) - 1:isNaN(kk + dd - 1) + 1) = newValues';

                    kk = kk + dd;
                end

                if kk == num
                    newValues = interp1(1:2,[tempIt(isNaN(num) - 1) tempIt(isNaN(num) + 1)],1:(1/2):2); 
                    tempIt(isNaN(num) - 1:isNaN(num) + 1) = newValues';
                end

                temp(:,ii) = tempIt;

            end

        end

    end

end

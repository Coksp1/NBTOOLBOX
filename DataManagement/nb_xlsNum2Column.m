function columns = nb_xlsNum2Column(num)

    num     = num(:);
    n       = size(num,1);
    columns = cell(1,n);
    for ii = 1:n
       columns{ii} = nb_num2letter(num(ii)); 
    end

end

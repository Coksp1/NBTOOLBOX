function nb_excel2coeff(filename)

    [p,n,~] = fileparts(filename);
    if isempty(p)
        fn = n;
    else
        fn = [p,filesep,n];
    end
    
    [~,~,l] = xlsread(filename);
    s = cell2struct(l(:,2),l(:,1));
    save([fn,'.mat'],'-struct','s');

end

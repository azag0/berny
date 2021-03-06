% reads z-matrix in gaussian format. 12/04/15

function zmat = zread(name)
%
fid = fopen(name,'r');

n = 0;
tline = fgetl(fid);
while ischar(tline)
    n = n+1;
    tlines{n} = tline; %#ok<AGROW>
    tline = fgetl(fid);
end
fclose(fid);

z = cell(n,7);
i = 1;
while i<=numel(tlines) && ~isempty(strtok(tlines{i}))
    s = tlines{i};
    for j = 1:7 ; [ss,s] = strtok(s); z{i,j} = ss; end
    z{i,1} = lower(z{i,1});
    i = i+1;
end
nat = i-1;
z = z(1:nat,:);

zval = cell(n-i,2);
m = 0;
for j = i+1:n
    s = tlines{j};
    if isempty(strtok(s)) ; break; end
    [cvar,cval] = strtok(s);
    m = m+1;
    zval{m,1} = cvar;
    zval{m,2} = str2double(cval);
    eval([cvar '=' cval ';']);
end
zval = zval(1:m,:);

zmat.def = z;
zmat.var = cell2mat(zval(:,2));

for k = 1:m
    idz = strmatch(zval{k,1},z,'exact');
    for j=1:length(idz) zmat.def{idz(j)} = num2str(-1000-k); end
end

for i = 1:nat 
    c = zmat.def{i,1};
    zmat.def{i,1} = element(c);
    for j = 2:7
        if isempty(zmat.def{i,j})
            zmat.def{i,j} = 0;
        else
            zmat.def{i,j} = eval(zmat.def{i,j});
        end
    end
end
zmat.def = cell2mat(zmat.def);

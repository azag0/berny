% main driver of the berny package. 12/04/13

function driver(name)
	global angstrom
	angstrom = 1.88972613288; % 1 angstrom in a.u.
	param = setparam(name); % set parameters
	if isempty(param.restart)
		fdelete([name '.xyz'],[name '.mat']);
		fid = fopen([name '.log'],'w'); % open logfile
		param.name = name;
		param.fid = fid;
		if strncmp(param.program,'vasp',4)
			geom = car2geom('POSCAR');
			fdelete('OSZICAR');
		elseif isfield(param,'geometry')
			geom = readX(param.geometry);
			geom.periodic = false;
		elseif isfield(param,'zmat')
			geom.zmat = zunits(zread(param.zmat),'toau');
			geom.atoms = geom.zmat.def(:,1);
			geom.n = length(geom.atoms);
			geom.xyz = zmat2xyz(geom.zmat);
			geom.periodic = false;
		end
		[void,node] = system('uname -n'); % where are we?
		fprintf(fid,'Node: %s\n',strtrim(node));
		fprintf(fid,'Time: %s\n',datestr(now()));
		fprintf(fid,'entering initialitation ...\n'); octfflush(fid);
		t = clock(); % start clock
		var = initiate(geom,param); % make initialization stuff
		fprintf(fid,'... finished in %.2f seconds\n',...
			etime(clock(),t)); octfflush(fid); % stop clock
	else
		S = load(param.restart);
		var = S.debug{end};
		s = fileread([name '.log']);
		fid = fopen([name '.log'],'w');
		fprintf(fid,s);
		fprintf(fid,'--- RESTART ---\n');
		[void,node] = system('uname -n'); % where are we?
		fprintf(fid,'Node: %s\n',strtrim(node));
		fprintf(fid,'Time: %s\n',datestr(now()));
		octfflush(fid);
		var.param.fid = fid;
	end
	state = false;
	for i = 1:param.maxsteps
		if i > 1 || isempty(param.restart)
			geom = var.geom;
			param = var.param;
			writeX(geom,[name '.xyz']); % write current geometry
			if isfield(param,'zmat')
				zwrite(zunits(geom.zmat,'toangstrom'),[name '.zmat']);
			end
			var.energy = getenergy(geom,param); % obtain energy
			fprintf(fid,'entering berny ...\n'); octfflush(fid);
			savedebug(var); % save variable environment into debug
		end
		t = clock(); % start clock
		[state,var] = berny(var); % perform berny
		fprintf(fid,'... finished in %.2f seconds\n',...
			etime(clock(),t)); octfflush(fid); % stop clock
		if state, break, end
		if i == param.maxsteps
			fprintf(fid,'Maximum number of steps reached\n');
		end
	end
	if state
		fprintf(fid,'Geometry converged in %i steps\n',i);
		if ~param.debug, fdelete([name '.mat']); end
	end
	fclose(fid);
end

function energy = getenergy(geom,param)
	energy.E = 0;
	energy.g = zeros(length(geom.atoms),3);
	if strncmp(param.program,'vasp',4)
		energy = vasp(geom,param);
	else
		switch param.program
			case 'gaussian'
				energy = gaussian(geom,param);
		end
	end
end


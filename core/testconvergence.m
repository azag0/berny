% tests for convergence criteria. 12/04/10

function state = testconvergence(g,dQ,dqq,trust)
	global param
	onsphere = abs(norm(dqq)-trust)<1e-10;
	names = {'Gradient RMS' 'Step RMS'...
		'Gradient maximum' 'Step maximum'};
	results = {'no' 'OK'};
	values = [rms(g) 0 max(abs(g)) 0];
	flags = logical([1 0 1 0]);
	if ~onsphere
		values([2 4]) = [rms(dQ) max(abs(dQ))];
		flags([2 4]) = true;
	end
	print('Convergence criteria:');
	isok = values < param.threshold;
	for i = 1:4
		if ~flags(i), continue, end
		print('* %s is: %.3g, threshold: %.3g, %s',...
			names{i},values(i),param.threshold(i),results{isok(i)+1});
	end
	isok = isok(flags);
	if onsphere
		print('* Minimization on sphere was performed, no');
		isok(end+1) = false;
	end
	state = all(isok);
	if state
		print('* All criteria matched');
	end
end

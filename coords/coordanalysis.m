% prints information about coordinates. 12/04/07

function coordanalysis(ind,nfrag)
	m = size(ind,1); % number of coordinates
	print('Coordinates information:');
	print('* Number of fragments: %g',nfrag);
	print('* Number of internal coordinates: %g',m);
	i = indexing(ind);
	ind(ind(:,5)>2,5) = 2; % reduce degrees to max 2
	degrees = [2 3 3]; % number of degrees for bond, angle, dihedral
	names = {'bonds' 'angles' 'dihedrals'};
	adjectives = {'strong' 'weak' 'superweak'};
	for k = 1:3
		for l = 1:degrees(k)
			number = sum(ind(i(k):i(k+1)-1,5)==(l-1));
			           % number of coordinates of type k and degree l
			if number > 0
				print('* Number of %s %s: %g',...
					adjectives{l},names{k},number);
			end
		end
	end
end

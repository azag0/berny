% Gives energy and gradient for atoms interacting pairwise
% via Morse potential. Optional second argument is a column 
% vector of dimensions of a rectangular cell: in that case,
% periodic system is calculated. 12/04/07

function [E,g] = morse(xyz,abc)
	V = @(r,r0)((1-exp(-(r-r0))).^2-1); % morse potential
	drV = @(r,r0)(2*(1-exp(-(r-r0))).*exp(-(r-r0))); % derivative
	r0 = 0.75; % equilibrium distance
	n = size(xyz,1); % number of atoms
	if nargin > 1 % if periodic
		range = 20; % cutoff range
		ncell = ceil(range./abc); % size of supercell
		super = copycell(xyz,diag(abc),[-ncell ncell]); % supercell
	else
		super = xyz; % supercell is only one cell
	end
	m = size(super,1); % number of atoms in supercell
	in = (1:n)';
	im = 1:m;
	delta = xyz(in(:,ones(1,m)),:)-super(im(ones(1,n),:),:);
	r = sqrt(sum(delta.^2,2)); % distances
	Vij = V(r,r0);
	Vij(find(triu(ones(n)))) = 0; 
	E = sum(Vij); % energy
	drVij = drV(r,r0);
	dxyzVij = reshape(drVij(:,ones(1,3)).*delta./r(:,ones(1,3)),n,m,3);
	dxyzVij(isnan(dxyzVij)) = 0;
	g = permute(sum(dxyzVij,2),[1 3 2]); % gradient
end


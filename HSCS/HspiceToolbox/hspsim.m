function hspsim(varargin)
if nargin == 0
   unix_command = 'hspsim';
else
parfile = char(varargin(1));
   unix_command = sprintf('hspsim %s',parfile);
end
unix(unix_command);

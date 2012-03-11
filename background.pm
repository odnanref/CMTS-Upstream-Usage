# 
# background.pm
# code to allow perl script to run in the background has daemon
#
#    Copyright (C) 2008 Fernando André < netriver at gmail . com >
#    
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
# License as published by the Free Software Foundation; Version 2 of the License
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS # FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with 
# this program; if not, write to the 
# Free Software Foundation, Inc., 59 Temple Place, Suite  330, Boston, MA 02111-1307 USA
# 
# A copy online can be found at http://www.gnu.org/licenses/gpl-2.0.html 
#
#

use POSIX;
use Email::Valid;

my $HOME	= "/tmp/";

sub daemonize {
	my $local = $0;
	$local =~ s/\.\///gi;
	$local =~ s/.pl//i;
	chdir $HOME               or die "Can't chdir to ".$HOME.": $!";
	open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
	defined(my $pid = fork) or die "Can't fork: $!";
	exit if $pid;
	setsid()                  or die "Can't start a new session: $!";
}


return 1;

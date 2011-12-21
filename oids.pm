#!/usr/bin/perl
#
# Get CMTS Status from upstream interfaces
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

	%cisco = (
        frequencia => '1.3.6.1.2.1.10.127.1.1.2.1.2.',
        modulacao => '1.3.6.1.2.1.10.127.1.1.2.1.4.',
        channelwidth => '1.3.6.1.2.1.10.127.1.1.2.1.3.',
		powerlevel => '1.3.6.1.2.1.10.127.1.2.2.1.3.',
		descricao => 'IF-MIB::ifDescr',
		online => '1.3.6.1.4.1.9.9.116.1.4.1.1.5.',
		total => '1.3.6.1.4.1.9.9.116.1.4.1.1.3.',
		snr => '1.3.6.1.2.1.10.127.1.1.4.1.5.',
		downstreamfreq => '1.3.6.1.2.1.10.127.1.1.1.1.2.'
    );

	%arris = (
        frequencia => '1.3.6.1.2.1.10.127.1.1.2.1.2.',
        modulacao => '1.3.6.1.2.1.10.127.1.1.2.1.4.',
        channelwidth => '1.3.6.1.2.1.10.127.1.1.2.1.3.',
		powerlevel => '',
		descricao => 'IF-MIB::ifDescr',
		online => '1.3.6.1.4.1.9.9.116.1.4.1.1.5.',
		total => '1.3.6.1.4.1.9.9.116.1.4.1.1.3.',
		snr => '1.3.6.1.2.1.10.127.1.1.4.1.5.',
		downstreamfreq => '1.3.6.1.2.1.10.127.1.1.1.1.2.'
    );


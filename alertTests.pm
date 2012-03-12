#
# alertTests.pm
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

my $NETCRASH =1;

=item alert_snr($Data, $cmts)

This function checks the snr value against the last obtained 
and tests for variation

=cut

sub alert_snr
{
	my ($Data, $cmts) = @_;
	
	if (defined($Data->{'snr'})) {
		#
		# test if field already exists in hash
		# check if alertsnr is enabled ALERTSNR = 1
		# verify if existed a variation of snr

		if ( defined($hashAlertSnr{$cmts}{ $Data->{"descr"} }) && 
			$ALERTSNR == 1 &&
			( (($Data->{"snr"})+0) < (($hashAlertSnr{$cmts}{ $Data->{"descr"} })-5) ) ) 
		{
			# ISSUE ALERT if diference between curent and old less then 5
			freq_alert(
				"SNR detectada diferença significativa desde ultima leitura \n"
				. "Ultima: ". $hashAlertSnr{$cmts}{ $Data->{"descr"} } ." \n"
				. "Actual: ".$Data->{"snr"}."\n"
				. "Interface " . $Data->{"descr"}."\n"
				, "[ALERTA] SNR de $cmts \n"
				);
		} else {
			if ($DEBUG == 2) {
				print "SNR DEBUG new:". $Data->{"snr"} .
					" snr last:".$hashAlertSnr{$cmts}{ $Data->{"descr"} }."\n";
			}
		}
		$hashAlertSnr{$cmts}{ $Data->{"descr"} } = $Data->{"snr"};
	}
}

=item alert_cm($data, $cmts)

This function checks the cable modem count and executes an alert if
a variation occurs

=cut

sub alert_cm {
	my($Data, $cmts) = @_;

	print "CM DEBUG: ALERT IN\n" if $DEBUG == 3;
	
	if (defined($Data->{'online'})) {
		if ( defined($hashAlertCM{$cmts}{ $Data->{"descr"} }) && 
			$ALERTCM == 1 &&
			( (($Data->{"online"})+0) < (($hashAlertCM{$cmts}{ $Data->{"descr"} })-10) ) ) 
		{
			freq_alert("Alerta total de modems online variou em 10\n" 
			. " # de CM online antes:" . $hashAlertCM{$cmts}{ $Data->{"descr"} } ."\n"
		    . " # de CM ONLINE AGORA:" . $Data->{'online'} . "\n"
			. " INTERFACE: " . $Data->{"descr"} ."\n" 
			, "[ALERTA] Cable modem Online: $cmts "
			);

		} else {
			if ($DEBUG == 3 ) {
				print "DEBUG CM ONLINE: "
				. " # de CM online antes:" . $hashAlertCM{$cmts}{ $Data->{"descr"} } ."\n"
				. " # de CM ONLINE AGORA:" . $Data->{'online'} . "\n"
				;
			}
		}
		$hashAlertCM{$cmts}{ $Data->{"descr"} } = $Data->{"online"};
	} else {
		if ($DEBUG == 3 ) {
			print "NO ONLINE HASH specified\n";
		}
	}
}

=item freq_alert($message, $subjet)

issue alert for message and subject

=cut

sub freq_alert {
	my ($message, $subject) = @_;
	
	my $sendmail	= "/usr/sbin/sendmail -t";
	my $reply_to	= "Reply-to: netriver+cableboy\@gmail.com\n"; # using
	my $subject		= "Subject: Reporting $subject \n";
	my $content		= $message;

	unless ($MAIL_TO) {
		print "Please fill in the email MAIL_TO";
		exit "failed reporting no MAIL_TO";
	}

	my $send_to = "To: ".$MAIL_TO;
	
	open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	print SENDMAIL $reply_to;
	print SENDMAIL $subject;
	print SENDMAIL $send_to;
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL $content;
	close(SENDMAIL);
	print "MESSAGE:".$message."\n";
}



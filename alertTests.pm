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

our %ignoreList = ();

my $NETCRASH =1;

=item alert_snr($Data, $cmts)

This function checks the snr value against the last obtained 
and tests for variation

=cut

sub alert_snr
{
	my ($Data, $cmts) = @_;
	
	if (defined($Data->{'snr'})) {

		if (ignoreUps($cmts,  $Data->{"descr"}) == 1) {
			print "DEBUG ignore lst: ignoring\n" if $DEBUG == 4;
			return 0;
		}

		#
		# test if field already exists in hash
		# check if alertsnr is enabled ALERTSNR = 1
		# verify if existed a variation of snr

		if ( defined($hashAlertSnr{$cmts}{ $Data->{"descr"} }) && 
			$ALERTSNR == 1 &&
			( (($Data->{"snr"})+0) < (($hashAlertSnr{$cmts}{ $Data->{"descr"} })-5) ) ) 
		{
			# ISSUE ALERT if diference between curent and old less then 5
			my $descr	= $Data->{"descr"};
			$descr		=~ s/\"//gi;
			freq_alert(
				"SNR detectada diferença significativa desde ultima leitura \n"
				. "Ultima: ". $hashAlertSnr{$cmts}{ $Data->{"descr"} } ." \n"
				. "Actual: ".$Data->{"snr"}."\n"
				. "Interface " . $descr ."\n"
				, "[ALERTA] SNR: $cmts $descr \n"
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

		if (ignoreUps($cmts,  $Data->{"descr"}) == 1) {
			print "DEBUG ignore lst: ignoring\n" if $DEBUG == 4;
			return 0;
		}

		if ( defined($hashAlertCM{$cmts}{ $Data->{"descr"} }) && 
			$ALERTCM == 1 &&
			( (($Data->{"online"})+0) < (($hashAlertCM{$cmts}{ $Data->{"descr"} })-10) ) ) 
		{
			my $descr = $Data->{"descr"};
			$descr =~ s/\"//gi;
			freq_alert("Alerta total de modems online variou em 10\n" 
			. " # de CM online antes:" . $hashAlertCM{$cmts}{ $Data->{"descr"} } ."\n"
		    . " # de CM ONLINE AGORA:" . $Data->{'online'} . "\n"
			. " INTERFACE: " . $descr ."\n" 
			, "[ALERTA] #CM: $cmts $descr "
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

=item loadIgnoreList

 Load ignore list to memory

 file: mycwd/ignore.ups

=cut

sub loadIgnoreList {
	
	if ($DEBUG == 4) {
		print "DEBUG ignore lst: STARTED\n";
	}

	if ( !-r($mycwd."/ignore.ups") ) {
		if ($DEBUG == 4 ) {
			print "DEBUG ignore lst: no file found... $mycwd/ignore.ups \n";
		}
		return 0;
	}
	
	print "DEBUG ignore lst: loading file $mycwd/ignore.ups \n" if $DEBUG == 4;
	
	my $file = $mycwd."/ignore.ups";	
	open(FH, $file) || die("frequsage.pl Failed opening file ignore.ups");
	my @DATA = <FH>;
	close(FH);
	
	foreach my $LINE_VAR (@DATA)
	{
		chomp($LINE_VAR);
		my ($cmts, $ups) = split(";", $LINE_VAR);
		if (defined($cmts) && defined($ups)) {
			print "DEBUG loading Ignore lst: ".$cmts. " - ".$ups."\n" if $DEBUG == 4;
			
			$ups =~ s/ |\"//gi;
			$ignoreList{$cmts}->{$ups} = 1; # assignment just for set
		}
	}
}

=item ignoreUps($cmts, $upstream)

	should ignore upstream alerts ?

	return (0, 1)
=cut

sub ignoreUps {
	my ($cmts, $ups) = @_;
	
	$ups	=~ s/ |\"//gi;
	
	if ($ignoreList{$cmts}->{$ups}) {
		print "DEBUG IGNORING upstream :".$cmts." - ".$ups."\n" if ($DEBUG == 4 );
		return 1;
	} else {
		print "DEBUG NOT IGNORING upstream :".$cmts." - ".$ups."\n" if ($DEBUG == 4);
	}

	return 0;
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


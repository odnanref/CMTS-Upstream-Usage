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
use strict;
#use Data::Dumper;
use oids;

my $walker = '/usr/bin/snmpwalk ';
my $totalOn = 0;
my $totalOff = 0;
my $totalAct = 0;
my $i;
my $id;
my $mib;
my (%hash);
my $outfile;
my $DEBUG=0;

#
# Passa os dados para um file CSV
#
sub toCSV
{
	my (%lista) = @_;
	
	my %value;
	my $csv;
	# Titulo do CSV
	$csv = '"Interface";"SNR";"Upstream Freq";"Upstream Modulacao";"Channel Width";"power level"'.
		';"online";"offline";"total";"Frequencia de Downstream"'.
		"\n";
	while ( my ($key, $value) = each(%lista) ) 
	{
        $csv .= '"'.$key .'";';
		$csv .= '"'.
				$lista{$key}{snr}.'";"'.
				$lista{$key}{frequencia}.'";"'.
				$lista{$key}{modulacao}.'";"'.
				$lista{$key}{channelwidth} . '";"'.
				$lista{$key}{powerlevel}.'";"'.
				$lista{$key}{online} . '";"'.
				$lista{$key}{offline} . '";"'.
				$lista{$key}{total}.'";"'.
				$lista{$key}{downstreamfreq} . '"'
				."\n";
    }
	
	if ($outfile ne '' )
	{
		print "nome do ficheiro csv ".$outfile.".csv \n";
		open(FH, "> ".$outfile.".csv");
		print FH $csv;
		close(FH);
	}
}
#
# LE a info do CMTS
#
sub SnrStatus {
	my (%lista);
	my $lista = %lista;
	my($cmts, $comunity, $style) = @_;
	
        if ( $style eq 'cisco' ) {
			%hash = %main::cisco;
			if ($DEBUG > 0)
			{
				print "Cisco loaded\n";
			}
        }elsif($style eq 'terayon'){
			my $mibCiscoSNRUp          = 'SNMPv2-SMI::transmission.127.1.1.4.1.5';
			my $mib = $mibCiscoSNRUp;
			if ($DEBUG > 0)
			{
				print "Terayon loaded\n";				
			}
        }elsif($style eq 'arris' ){	
			%hash = %main::arris;
			if ($DEBUG > 0)
			{
				print "Arris loaded\n";				
			}
		}

	my $descroid = $hash{descricao};
	if ($DEBUG > 0)
	{
		print "$walker -v1 -c $comunity $cmts $descroid\n";
	}
	
	my @out = `$walker -v1 -c $comunity $cmts $descroid `;
    
	foreach $i (@out) {
		chomp($i);
		my ( $v, $maters) = split(/\./, $i);
		my ($id, $descr) = split(/=/, $maters);
		$descr =~ s/STRING: //gi;
		if ($DEBUG > 0) 
		{
			print "descr:".$descr."\n";
		}
		$mib = $hash{snr}.$id; # snr mib
		my ($tmp, $snr) = split(/INTEGER: /,`$walker -v1 -c $comunity $cmts $mib`);
		$snr = ($snr/10);
		$lista{ $descr }{snr} = $snr;
		
		$mib = $hash{frequencia}.$id;
		my ($tmp, $upfreq) = split(/INTEGER: /, `$walker -v1 -c $comunity $cmts $mib` );
		chomp($upfreq);
		$lista{ $descr }{frequencia} = $upfreq;
		
		$mib = $hash{modulacao}.$id;
		my ($tmp, $tmp2) = split(/INTEGER: /, `$walker -v1 -c $comunity $cmts $mib` );
		chomp($tmp2);
		$lista{ $descr }{modulacao} = $tmp2;
		
		$mib = $hash{channelwidth}.$id;
		my ($tmp, $tmp2) = split(/INTEGER: /, `$walker -v1 -c $comunity $cmts $mib` );
		chomp($tmp2);
		$lista{ $descr }{channelwidth} = $tmp2;
		
		$mib = $hash{online}.$id;
		my ($tmp, $tmp2) = split(/INTEGER: /, `$walker -v1 -c $comunity $cmts $mib` );
		chomp($tmp2);
		$lista{ $descr }{online} = $tmp2;
		
		$mib = $hash{total}.$id;
		my ($tmp, $tmp2) = split(/INTEGER: /, `$walker -v1 -c $comunity $cmts $mib` );
		chomp($tmp2);
		$lista{ $descr }{total} = $tmp2;
		
		$lista{$descr}{offline} = $lista{ $descr }{total} - $lista{ $descr }{online};
		
		$mib = $hash{downstreamfreq}.$id;
		my ($tmp, $tmp2) = split(/INTEGER: /, `$walker -v1 -c $comunity $cmts $mib` );
		chomp($tmp2);
		$lista{ $descr }{downstreamfreq} = $tmp2;
	}
	print "preparing output\n";
	toCSV(%lista);
}


#
# Codigo inicia-se aqui
#
print " cmtsUsage \n";
print " A iniciar com argumentos 0=".$ARGV[0]." 1=".$ARGV[1]." 2=".$ARGV[2]." 3=".$ARGV[3]."\n";
if ($ARGV[0] ne '--file'){
	my $fail = 0 ;
	if ($ARGV[1] eq ''){
		print "Argumento 1 deve indicar o IP.\n";
		$fail = 1;
	}
	
	if ($ARGV[2] eq ''){
		print "Argumento 2 deve indicar a community.\n";
		$fail = 1;
	}
	
	if ($ARGV[3] eq ''){
		print "Argumento 3 deve indicar o tipo de cmts ex(cisco).\n";
		$fail = 1;
	}
	
	if ($ARGV[4] eq ''){
		print "Argumento 4 deve indicar o ficheiro csv.\n";
		$fail = 1;
	}
	
	print "Also available read the options from a file list with ; separating the fields\n";
	print "example line in file = IP;COMMUNITY;TYPE\n";
	print "pass argument --file NAME_OF_FILE.txt\n";
	
	if ($fail == 0){
		$outfile = $ARGV[4];
		SnrStatus($ARGV[1], $ARGV[2], $ARGV[3]);
	}
	
}else{
	my $file = $ARGV[1];
	if ( !-r $file)
	{
		die("Unable to read file $file\n");	
	}
	open(FH, "< ".$file);
	my @lista = <FH>;
	close(FH);
	my $k;
	foreach $k (@lista){
		my ($ip, $community, $type ) = split(/;/, $k);
		$ip =~ s/\"//gi;
		$community =~ s/\"//gi;
		$type =~ s/\"//gi;
		chomp($type);
		$outfile = $ip;
		$outfile =~ s/\.//gi;
		print "A ler ".$ip." ".$community." ".$type." para ficheiro csv ".$outfile.".csv \n";
		SnrStatus($ip, $community, $type);		
	}
} 
# Last parameter should be cisco usually in case of terayon CMTS I have found the second oid to work with terayon cmts
#
# Para a proxima versao
# $numArgs = $#ARGV + 1;
# print "thanks, you gave me $numArgs command-line arguments.\n";
#
# foreach $argnum (0 .. $#ARGV) {
#    print "$ARGV[$argnum]\n";
#	if ( $ARGV[$argnum] eq '' ){
#	
#	}
# }


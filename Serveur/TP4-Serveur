#!/usr/bin/env perl

#Ajout des librairies
use IO::Socket;
use Digest::MD5 qw(md5_hex);

#Declaration des variable
my $protocole = "tcp";
my $port = 2554;
my $input = "";

$serveur = IO::Socket::INET->new( Proto => $protocole,
LocalPort => $port,
Listen => SOMAXCONN,
Reuse => 1)
or die "Impossible de se connecter sur le port $port en localhost";

while (my $connection = $serveur->accept())
{
	print $connection "TP4 - Serveur de courriels\n";
	while($input ne "quit\r\n")
	{
		chomp($input = <$connection>);
		print $input;
		print $connection "Merci ~serveur\n";

	}
	close($connection);
}





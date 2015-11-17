#!/usr/bin/env perl

#Ajout des librairies
use IO::Socket;
use Digest::MD5 qw(md5_hex);
use MIME::Lite;

#Declaration des variable
my $protocole = "tcp";
my $port = 2554;
my $input = "";
my $configfilepath = "/config/config.txt";
my $userconfigfilepath = "/user/";
my $protocole = "tcp";
my $printmenu = "Menu\n
				1. Envoi de courriels\n
				2. Consultation de courriels\n
				3. Statistiques\n
				4. Mode administrateur\n
				5. Quitter\n";



print "Avant main\n";
&main;



sub checkuservalidity
{
	print "Begin checkuservalidity\n";
	my $username = $_[0];
	my $cipheredpassword = $_[1];
	open(my $fh, '<:encoding(UTF-8)', "$userconfigfilepath$username/config.txt")
  		or die return false;

	my $firstline = <$fh>;
	print "End checkuservalidity\n";
	$firstline eq cipheredpassword;
}



sub stringcontains
{
	print "Begin stringcontains\n";
	my $mystring = $_[0];
	my $searchedtext = $_[1];

	print "End stringcontains\n";
	$mystring =~ /$searchedtext/;
}

sub askclientidentification
{
	print "Begin askclientidentification\n";
	my $clientconnection = $_[0];
	my $username = "";
	my $cipheredpassword = "";
	my $successfulidentification;
	
	print $clientconnection "Veuillez vous identifier\n";
	print $clientconnection "Nom d'utilisateur: \n";
	chomp($username = <$clientconnection>);
	print $clientconnection "Mot de passe: \n";
	chomp($cipheredpassword = <$clientconnection>);

	print "End askclientidentification\n";
	&checkuservalidity($username, $cipheredpassword);
}

sub startserveur
{
	print "Begin startserveur\n";
	my $port = $_[0];
	$serveur = IO::Socket::INET->new( Proto => $protocole,
	LocalPort => $port,
	Listen => SOMAXCONN,
	Reuse => 1)
	or die "Impossible de se connecter sur le port $port en localhost";
	print "End startserveur\n";
	$serveur;
}

sub main
{
	print "Begin main\n";
  	my $server = &startserveur($port);
#	while (my $connection = $serveur->accept())
#	{
#		print $connection "TP4 - Serveur de courriels\n";
#		while($input ne "quit\r\n")
#		{
#			
#
#		}
#		close($connection);
#	}
#
  	while (my $connection = $serveur->accept())
	{
		my $desirequitter = false;
		if (&askclientidentification($connection))
		{
			while ($desirequitter eq false)
			{
				print $connection $printmenu;
				chomp($input = <$connection>);
				#print $input;
				#print $connection "Merci ~serveur\n";
			}
		}
	}
}

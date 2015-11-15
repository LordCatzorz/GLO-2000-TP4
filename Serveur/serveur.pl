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
				5. Quitter\n"




main();

sub main
{
  	$port = getport($configfilepath)
  	my $server = startserveur($port);

	while (my $connection = $serveur->accept())
	{
		print $connection "TP4 - Serveur de courriels\n";
		while($input ne "quit\r\n")
		{
			

		}
		close($connection);
	}

  	while (my $connection = $serveur->accept())
	{
		my $desirequitter = false;
		if (askclientidentification())
		{
			while (desirequitter eq false)
			{
				print $printmenu;
				chomp($input = <$connection>);
				print $input;
				print $connection "Merci ~serveur\n";
			}
		}
	}
}

sub askclientidentification
{
	my $username = "";
	my $cipheredpassword = "";
	my $successfulidentification
	
	print $connection "Veuillez vous identifier\n";
	print $connection "Nom d'utilisateur: \n";
	chomp($username = <$connection>);
	print $connection "Mot de passe: \n";
	chomp($cipheredpassword = <$connection>);
	
	return checkuservalidity($username, $cipheredpassword);
}

sub checkuservalidity
{
	my $username = $_[0];
	my $cipheredpassword = $_[1];
	open(my $fh, '<:encoding(UTF-8)', "$userconfigfilepath$username/config.txt")
  		or die return false;

	my $firstline = <$fh>;
	return ($firstline eq cipheredpassword)
}

sub startserveur
{
	my $port = $_[0];

	$serveur = IO::Socket::INET->new( Proto => $protocole,
	LocalPort => $port,
	Listen => SOMAXCONN,
	Reuse => 1)
	or die "Impossible de se connecter sur le port $port en localhost";
	return $serveur;
}

sub getport
{
	open(my $fh, '<:encoding(UTF-8)', $filename)
  		or die "Impossible d'ouvrir le fichier de configuration ($configfilepath)!";

  	while (my $row = <$fh>) 
  	{
  		chomp $row;
  		if (stringcontains($row, "port:"))
  		{
  			my $portnumber =~ s/$row//;
  			return $portnumber
  		}
	}
	return 25; #Default
}

sub stringcontains
{
	my $mystring = $_[0];
	my $searchedtext = $_[1];

	return ($mystring =~ /$searchedtext/);
}




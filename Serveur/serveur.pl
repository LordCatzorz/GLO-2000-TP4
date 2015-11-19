#!/usr/bin/env perl



#Ajout des librairies

use IO::Socket;

#use Digest::MD5 qw(md5_hex);

use MIME::Lite;
use File::Basename qw();



#Declaration des variable

my $protocole = "tcp";

my $port = 2559;

my $input = "";

my $configfilepath = "/config/config.txt";

#my $userconfigfilepath = "/user/";

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

	my ($name, $path, $suffix) = File::Basename::fileparse($0);

	my $username = $_[0];
	print "Username recu $username\n";

	my $cipheredpassword = $_[1];
	print "Password recu $cipheredpassword\n";
	my $configfile = '/config.txt';
	$path = "$path$username$configfile";
	print "Path $path\n";
	opendir (my $dh, $directory);

	open(my $fh, '<:encoding(UTF-8)', $path)

  		or die return 0;



	my $firstline = <$fh>;
	close $fh;

	print "End checkuservalidity\n";

	if ($firstline eq uc($cipheredpassword))
	{
		return 1;
	}
	return 0;

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

	return &checkuservalidity($username, $cipheredpassword);

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

  	while (my $connection = $serveur->accept())

	{

		my $desirequitter = false;

		if (&askclientidentification($connection))

		{
			print $connection "Authentification reussie\n";
			print "recevoir choix";

			chomp($input = <$connection>);
			print "$input";

			while ($desirequitter eq false)

			{

				#print $connection $printmenu;
				print "recevoir choix";

				chomp($input = <$connection>);
				print "$input";
				if ($input == 1)
				{
					print "Choix 1";
				}
				elsif ($choice == 2)

				{
				}

			}

		}
		else
		{
			print $connection "Authentification echouee\n";
			close($connection);
		}

	}

}
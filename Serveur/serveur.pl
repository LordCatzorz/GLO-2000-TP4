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

my $username = "";







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

	
	my $cipheredpassword = "";

	
	$clientconnection->send("Veuillez vous identifier");

	$clientconnection->send("Nom d'utilisateur:");
	$clientconnection->recv($username, 1024);

	$clientconnection->send("Mot de passe:");
	$clientconnection->recv($cipheredpassword, 1024);

	my $successfulidentification = &checkuservalidity($username, $cipheredpassword);;

	print "End askclientidentification ($successfulidentification)\n";

	return $successfulidentification;

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

  	while (1)
  	{
  		print "En attente d'une connection\n";
  		$connection = $serveur->accept();
		my $client_address = $connection->peerhost();
   	 	my $client_port = $connection->peerport();
    	print "connection reçu de $client_address:$client_port\n";

		my $desirequitter = false;

		if (&askclientidentification($connection))
		{
			$connection->send("OK");
			$connection->send("Authentification réussi.\nBonjour $username");
			#print $connection $printmenu;
			while (1)
			{
				$connection->send($printmenu);
				print "En attente du choix de menu\n";
				$connection->recv($input, 1024);
				print "Reçu client : $input\n";
	
				if ($input == "1")
				{
					$connection->send("Quelle est l'adresse de destination:");
					my $destAdr = "";
					$connection->recv($destAdr, 1024);																																													
			
					$connection->send("Quelle est l'adresse en copie conforme:");
					my $ccAdr = "";
					$connection->recv($ccAdr, 1024);
			
					$connection->send("Quel est le sujet:");
					my $subject = "";
					$connection->recv($subject, 1024);
			
					$connection->send("Quel est le corps du message:");
					my $body = "";
					$connection->recv($body, 1048576);
	
	
	
	
				}
				elsif ($input == "2")
				{
					
				}
				elsif ($input == "3")
				{
					
				}
				elsif ($input == "4")
				{
					
				}
				elsif ($input == "5")
				{
					$connection->close();
				}
			}

		}
		else
		{
			$connection->send("Authentification échouée.\nFermeture de la connection.");
			$connection->close();
		}

	
	}

}
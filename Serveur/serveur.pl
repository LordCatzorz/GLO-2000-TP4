#!/usr/bin/env perl



#Ajout des librairies

use IO::Socket;

#use Digest::MD5 qw(md5_hex);

use MIME::Lite;
use File::Basename qw();
use File::Path qw(make_path);



#Declaration des variable

my $protocole = "tcp";

my $port = 2559;

my $input = "";

my $configfilepath = "/config/config.txt";

my $adresseApplication = "reseauglo.ca";
#my $userconfigfilepath = "/user/";

my $protocole = "tcp";

my $printmenu = "Menu\n
1. Envoi de courriels\n
2. Consultation de courriels\n
3. Statistiques\n
4. Mode administrateur\n
5. Quitter\n";

my $username = "";

&main;

sub checkuservalidity

{
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

	if ($firstline eq uc($cipheredpassword))
	{
		return 1;
	}
	return 0;

}

sub stringcontains

{

	my $mystring = $_[0];

	my $searchedtext = $_[1];

	$mystring =~ /$searchedtext/;

}



sub askclientidentification

{
	my $clientconnection = $_[0];

	
	my $cipheredpassword = "";

	
	$clientconnection->send("Veuillez vous identifier");

	$clientconnection->send("Nom d'utilisateur:");
	$clientconnection->recv($username, 1024);

	$clientconnection->send("Mot de passe:");
	$clientconnection->recv($cipheredpassword, 1024);

	my $successfulidentification = &checkuservalidity($username, $cipheredpassword);

	return $successfulidentification;
}

sub userexist
{
	my $searcheduser = $_[0];

	print "User exist : ./$searcheduser\n";
	if (-d "./$searcheduser")
	{
		return 1
	}
	return 0;
}

sub startserveur

{
	my $port = $_[0];

	$serveur = IO::Socket::INET->new( Proto => $protocole,

	LocalPort => $port,

	Listen => SOMAXCONN,

	Reuse => 1)

	or die "Impossible de se connecter sur le port $port en localhost";

	$serveur;

}

sub creerfichiermessage
{
	chomp(my $destadr = $_[0]);
	chomp(my $ccadr = $_[1]);
	chomp(my $sujet = $_[2]);
	chomp(my $corps = $_[3]);

	(my $destadruser, my $destadrdomain) = split ('@',$destadr);
	(my $ccadruser, my $ccadrdomain) = split ('@',$ccadr);

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

	my $contenuFichier = "Date et temps : $year-$mon-$mday $hour:$min:$sec\n
De: $username$adresseApplication\n
A: $destadr\n
CC: $ccadr\n
Sujet: $sujet\n
Corps: \n
$corps";
	

	my $filename = "$year$mon$mday-$hour$min$sec.txt";

	if ($destadrdomain eq $adresseApplication)
	{
		my $destuser = $destadruser;
		if (&userexist($destuser) eq 0)
		{
			$destuser = "DESTERREUR";
		}
		my $path = "./$destuser/recu/dest/";
		print "Creation de fichier dans $path$filename\n";
		eval{make_path($path)};
		my $file = "$path$filename";
		open FILE, '>'.$file;
		print FILE $contenuFichier;
		close FILE;
	}
	else
	{
		print "SMTP : Dest:$destadr\n";
		#smtp
	}

	if ($ccadrdomain eq $adresseApplication)
	{
		my $ccuser = $ccadruser;
		if (&userexist($dccuser) eq 0)
		{
			$ccuser = "DESTERREUR";
		}
		my $path = "./$ccuser/recu/cc/";
		print "Creation de fichier dans $path$filename\n";
		eval{make_path($path)};
		my $file = "$path$filename";
		open FILE, '>'.$file;
		print FILE $contenuFichier;
		close FILE;
	}
	else
	{
		print "SMTP : CC:$ccadr\n";
		#smtp
	}

	my $path = "./$username/envoye/";
	print "Creation de fichier dans $path$filename\n";
	eval{make_path($path)};
	my $file = "$path$filename";
	open FILE, '>'.$file;
	print FILE $contenuFichier;
	close FILE;
}


sub main

{

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
				$connection->flush();
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
					my $sujet = "";
					$connection->recv($sujet, 1024);
			
					$connection->send("Quel est le corps du message:");
					my $corps = "";
					$connection->recv($corps, 1048576);
	
					
					&creerfichiermessage($destAdr, $ccAdr, $sujet, $corps);
					
					$connection->send("Message envoyé");
	
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
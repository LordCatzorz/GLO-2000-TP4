#!/usr/bin/env perl



#Ajout des librairies

use IO::Socket;

#use Digest::MD5 qw(md5_hex);

use MIME::Lite;
use File::Basename qw();
use File::Path qw(make_path);
use Getopt::Long;
use File::stat;


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
	my $cipheredpassword = $_[1];

	my $configfile = '/config.txt';
	$path = "$path$username$configfile";

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

	my $successfulidentification = checkuservalidity($username, $cipheredpassword);

	return $successfulidentification;
}

sub userexist
{
	my $searcheduser = $_[0];

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

	$serveur->autoflush(1);
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

	$msg = MIME::Lite->new(
	From => "$username@$adresseApplication",
	To => "$destadr",
	Cc => "$ccadr",
	Subject => "$sujet",
	Data => "$corps"
	);
	

	my $sendwithsmtp = 0;

	my $filename = "$year$mon$mday-$hour$min$sec.txt";

	if ($destadrdomain eq $adresseApplication)
	{
		my $destuser = $destadruser;
		if (&userexist($destuser) eq 0)
		{
			$destuser = "DESTERREUR";
		}
		my $path = "./$destuser/recu/dest/";
		eval{make_path($path)};
		my $file = "$path$filename";
		open FILE, '>'.$file;
		print FILE $msg->as_string;;
		close FILE;
	}
	else
	{
		$sendwithsmtp = 1;
	}

	if ($ccadrdomain eq $adresseApplication)
	{
		my $ccuser = $ccadruser;
		if (&userexist($dccuser) eq 0)
		{
			$ccuser = "DESTERREUR";
		}
		my $path = "./$ccuser/recu/cc/";
		eval{make_path($path)};
		my $file = "$path$filename";
		open FILE, '>'.$file;
		print FILE $msg->as_string;;
		close FILE;
	}
	else
	{
		$sendwithsmtp = 1;
	}

	my $path = "./$username/envoye/";
	eval{make_path($path)};
	my $file = "$path$filename";
	open FILE, '>'.$file;
	print FILE $msg->as_string;
	close FILE;

	if ($sendwithsmtp eq 1)
	{
		$msg->send('smtp', "smtp.ulaval.ca", Timeout=>60);
	}
}

sub getlistfileinpath
{
	my $path = $_[0];

	my @listofsubjet;
	opendir my $dir, "$path";
	my @files = readdir $dir;

	foreach $file (@files)
	{
		if ($file =~ /.txt$/)
		{
			push @listofsubjet, "$path/$file";
		}
	}

	@listofsubjet;

}

sub getlistfilereceived
{
	my @listofsubjet;
	push @listofsubjet, &getlistfiledest($_[0]);
	push @listofsubjet, &getlistfilecc($_[0]);
	@listofsubjet;
}

sub getlistfilecc
{
	&getlistfileinpath("./$_[0]/recu/cc");
}

sub getlistfiledest
{
	&getlistfileinpath("./$_[0]/recu/dest");
}

sub getlistfilesend
{
	&getlistfileinpath("./$_[0]/envoye");
}

sub gettaillefichier
{
	my $filename = $_[0];
	$myresult = GetOptions ( "filename=s" => \$filename );
	my $filesize = stat($filename)->size;
	$filesize
}

sub getstatsfichiers
{
	my @listoffile = @_;

	my $nombreFichier = 0;
	my $taille = 0;
	my $stringSujet = "";

	foreach my $file (@listoffile)
	{
  		++$nombreFichier;
  		$taille = $taille + &gettaillefichier($file);
		open FICHIER, $file;
		while (my $ligne = <FICHIER>) 
		{
  			if ($ligne =~ /^Subject: /)
  			{	
  				$ligne =~ s/Subject: //;
  			 	$stringSujet = "$stringSujet"."$nombreFichier - $ligne\n";
  			}
		}
		close FICHIER;
	}
	($nombreFichier, $taille, $stringSujet);

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
			$connection->send("Authentification réussi.\nBonjour $username\n");
			$connection->flush();
			while ($connection->connected)
			{
				print "Affichage menu. Attente d'action.\n";
				$connection->flush();
				$connection->send($printmenu);
				$connection->recv(my $choixMenu, 1024);
	
				if ($choixMenu == "1")
				{
					print "Mode 1 sélectionné. Envoie de courriels.\n";
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
				elsif ($choixMenu == "2")
				{
					print "Mode 2 sélectionné. Consultation de courriels.\n";
					my @listoffile = &getlistfilereceived($username);
					
					if (scalar @listoffile > 0)
					{
						$connection->send("OK");
						my @stats = &getstatsfichiers(@listoffile);
						$connection->send(@stats[2]);
						$connection->recv(my $choix, 1024);
	
						open FICHIER, "<@listoffile[$choix-1]";
						undef $/; #Pour lire tous le fichier;
						my $contenuFichier = <FICHIER>;
						close FICHIER;
						$/ = "\n";
						$connection->send($contenuFichier);
					}
					else
					{
						$connection->send("Erreur: Aucun courriel reçu");
					}
				}
				elsif ($choixMenu == "3")
				{
					my @listecc = &getlistfilecc($username);
					my @listedest = &getlistfiledest($username);
					my @listesend = &getlistfilesend($username);

					my @statscc = &getstatsfichiers(@listecc);
					my @statsdest = &getstatsfichiers(@listedest);
					my @statssend = &getstatsfichiers(@listesend);

					my $nbTotal = @statscc[0] + @statsdest[0] + @statssend[0];
					my $tailleTotale = @statscc[1] + @statsdest[1] + @statssend[1];
					my $stringToSend = "
Voici les statistiques de votre compte:\n
---------------------------------------\n
TOTAL
Nombre de messages : $nbTotal \n
Taille : $tailleTotale\n
---------------------------------------\n
MESSAGES ENVOYÉS\n
Nombre de messages : @statssend[0]\n
Taille : @statssend[1]\n
Liste des sujets : \n
$statssend[2]
---------------------------------------\n
MESSAGES REÇUS\n
Nombre de messages : @statsdest[0]\n
Taille : @statsdest[1]\n
Liste des sujets : \n
$statsdest[2]
---------------------------------------\n
MESSAGES COPIE CONFORME\n
Nombre de messages : @statscc[0]\n
Taille : @statscc[1]\n
Liste des sujets : \n
$statscc[2]
---------------------------------------\n";
				
					$connection->send($stringToSend);
				}
				elsif ($choixMenu == "4")
				{
					
				}
				elsif ($choixMenu == "5")
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
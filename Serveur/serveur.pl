#!/usr/bin/env perl

use strict;
use warnings;

#Ajout des librairies

use IO::Socket;
use FindBin;

use MIME::Lite;
use File::Basename qw();
use File::Path qw(make_path);
use Getopt::Long;
use File::stat;


#Declaration des variable

my $protocole = "tcp";

my $port = 2559;

my $input = "";

my $adresseApplication = "reseauglo.ca";
#my $userconfigfilepath = "/user/";

my $printmenu = "Menu\n
1. Envoi de courriels\n
2. Consultation de courriels\n
3. Statistiques\n
4. Mode administrateur\n
5. Quitter\n";

my $username = "";

&main;

sub readtransmission
{
	local $/ = "!EOT!";
	my $connection = $_[0];
	my $transmission = readline($connection);
	#print "Received : $transmission\n";
	if ($transmission =~ /\!EOT\!/ )
	{
		$transmission =~ s/\!EOT\!$//;
		$transmission;
	}
	else
	{
		print "Erreur lors de la lecture. Fermeture de la connection.\n";
		&sendtransmission($connection, "Erreur lors de la lecture. Fermeture de la connection.");
		$connection->close;
	}
}

sub sendtransmission
{
	local $/ = "!EOT!";
	my $connection = $_[0];
	my $transmission = $_[1];
	#print "sent : $transmission!EOT!\n";
	print $connection "$transmission!EOT!";
}

sub checkuservalidity
{
	my ($name, $path, $suffix) = File::Basename::fileparse($0);

	my $username = $_[0];
	my $cipheredpassword = $_[1];

	my $configfile = '/config.txt';
	$path = "$path$username$configfile";

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
	
	&sendtransmission($clientconnection, "Veuillez vous identifier");
	&sendtransmission($clientconnection, "Nom d'utilisateur:");
	$username = &readtransmission($clientconnection);

	&sendtransmission($clientconnection, "Mot de passe:");
	$cipheredpassword = &readtransmission($clientconnection);

	my $successfulidentification = checkuservalidity($username, $cipheredpassword);

	return $successfulidentification;
}

sub userexist
{
	my $searcheduser = $_[0];

	if (-d "$FindBin::Bin/$searcheduser")
	{
		return 1
	}
	return 0;
}

sub startserveur
{
	my $port = $_[0];

	my $serveur = IO::Socket::INET->new( Proto => $protocole,

	LocalPort => $port,

	Listen => SOMAXCONN,

	Reuse => 1)

	or die "Impossible de se connecter sur le port $port en localhost";

	$serveur->autoflush;
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

	(my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();

	my $msg = MIME::Lite->new(
	From => "$username".'@'."$adresseApplication",
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
		my $path = "$FindBin::Bin/$destuser/recu/dest/";
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
		if (&userexist($ccuser) eq 0)
		{
			$ccuser = "DESTERREUR";
		}
		my $path = "$FindBin::Bin/$ccuser/recu/cc/";
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

	my $path = "$FindBin::Bin/$username/envoye/";
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

	foreach my $file (@files)
	{
		if ($file =~ /.txt$/)
		{
			push @listofsubjet, "$path/$file";
		}
	}

	@listofsubjet;

}

sub getlistusers
{
	opendir my $dir, $FindBin::Bin;
	my @files = readdir $dir;
	my @listofuser;
	
	foreach my $file (@files)
	{
		if ($file !~ /\./ and $file !~ /^admin$/ and $file !~ /^DESTERREUR$/)
		{
			push @listofuser, "$file";
		}
	}
	@listofuser;
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
	&getlistfileinpath("$FindBin::Bin/$_[0]/recu/cc");
}

sub getlistfiledest
{
	&getlistfileinpath("$FindBin::Bin/$_[0]/recu/dest");
}

sub getlistfilesend
{
	&getlistfileinpath("$FindBin::Bin/$_[0]/envoye");
}

sub gettaillefichier
{
	my $filename = $_[0];
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

sub getstatsutilisateur
{
	my $utilisateurdesiree = $_[0];
	my @listecc = &getlistfilecc($utilisateurdesiree);
	my @listedest = &getlistfiledest($utilisateurdesiree);
	my @listesend = &getlistfilesend($utilisateurdesiree);

	my @statscc = &getstatsfichiers(@listecc);
	my @statsdest = &getstatsfichiers(@listedest);
	my @statssend = &getstatsfichiers(@listesend);

	my $nbTotal = $statscc[0] + $statsdest[0] + $statssend[0];
	my $tailleTotale = $statscc[1] + $statsdest[1] + $statssend[1];
	my $stringToSend = "
Voici les statistiques de $utilisateurdesiree:\n
---------------------------------------\n
TOTAL
Nombre de messages : $nbTotal \n
Taille : $tailleTotale\n
---------------------------------------\n
MESSAGES ENVOYÉS\n
Nombre de messages : $statssend[0]\n
Taille : $statssend[1]\n
Liste des sujets : \n
$statssend[2]
---------------------------------------\n
MESSAGES REÇUS\n
Nombre de messages : $statsdest[0]\n
Taille : $statsdest[1]\n
Liste des sujets : \n
$statsdest[2]
---------------------------------------\n
MESSAGES COPIE CONFORME\n
Nombre de messages : $statscc[0]\n
Taille : $statscc[1]\n
Liste des sujets : \n
$statscc[2]
---------------------------------------\n";
	
	$stringToSend;		
}


sub main
{
  	my $server = &startserveur($port);

  	while (1)
  	{
  		print "En attente d'une connection\n";
  		my $connection = $server->accept();
		my $client_address = $connection->peerhost();
   	 	my $client_port = $connection->peerport();
    	print "connection reçu de $client_address:$client_port\n";

		my $desirequitter = 0;

		if (&askclientidentification($connection))
		{
			&sendtransmission($connection, "OK");
			&sendtransmission($connection, "Authentification réussi.\nBonjour $username");
			$connection->flush;
			while ($connection->connected)
			{
				print "Affichage menu. Attente d'action.\n";
				$connection->flush();
				&sendtransmission($connection, $printmenu);
				my $choixMenu = &readtransmission($connection);
	
				if ($choixMenu == "1")
				{
					print "Mode 1 sélectionné. Envoie de courriels.\n";
					if ($username ne "admin")
					{
						&sendtransmission($connection, "OK");
						
						&sendtransmission($connection, "Quelle est l'adresse de destination:");
						my $destAdr = "";
						$destAdr = &readtransmission($connection);																																													
				
						&sendtransmission($connection, "Quelle est l'adresse en copie conforme:");
						my $ccAdr = "";
						$ccAdr = &readtransmission($connection);
				
						&sendtransmission($connection, "Quel est le sujet:");
						my $sujet = "";
						$sujet = &readtransmission($connection);
				
						&sendtransmission($connection, "Quel est le corps du message:");
						my $corps = "";
						$corps = &readtransmission($connection);
		
						
						&creerfichiermessage($destAdr, $ccAdr, $sujet, $corps);
						
						&sendtransmission($connection, "Message envoyé");
					}	
					else
					{
						&sendtransmission($connection, "Les administrateurs ne peuvent pas envoyer de courriels");
					}
	
				}
				elsif ($choixMenu == "2")
				{
					print "Mode 2 sélectionné. Consultation de courriels.\n";
					my @listoffile = &getlistfilereceived($username);
					
					if (scalar @listoffile > 0)
					{
						&sendtransmission($connection, "OK");
						my @stats = &getstatsfichiers(@listoffile);
						&sendtransmission($connection, $stats[2]);
						my $choix = &readtransmission($connection);
	
						open FICHIER, "<$listoffile[$choix-1]";
						undef $/; #Pour lire tous le fichier;
						my $contenuFichier = <FICHIER>;
						close FICHIER;
						$/ = "\n";
						&sendtransmission($connection, $contenuFichier);
					}
					else
					{
						&sendtransmission($connection, "Erreur: Aucun courriel reçu");
					}
				}
				elsif ($choixMenu == "3")
				{
					print "Mode 3 sélectionné. Consultation de statistq¸ues.\n";
					my $stringToSend = &getstatsutilisateur($username);
				
					&sendtransmission($connection, $stringToSend);
				}
				elsif ($choixMenu == "4")
				{
					print "Mode 4 sélectionné. Administrateur.\n";
					if ($username eq "admin")
					{
						my @listofusers = &getlistusers;
						if (scalar @listofusers > 0)
						{
							&sendtransmission($connection, "OK");
							my $incrementor = 0;
							my $sentList = "";
							foreach my $user (@listofusers)
							{
								++$incrementor;
								$sentList = "$sentList\n$incrementor - $user";
							}
							&sendtransmission($connection, $sentList);
							my $choixUtilisateur = &readtransmission($connection);
							&sendtransmission($connection, &getstatsutilisateur($listofusers[$choixUtilisateur - 1]));
						}
						else
						{
							&sendtransmission($connection, "Aucun utilisateur disponible");
						}
					}
					else
					{
						&sendtransmission($connection, "Disponible pour les administrateurs seulement");
					}
				}
				elsif ($choixMenu == "5")
				{
					$connection->close();
				}
			}
		}
		else
		{
			&sendtransmission($connection, "Authentification échouée.\nFermeture de la connection.");
			$connection->close();
		}	
	}
}


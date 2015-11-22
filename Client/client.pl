#!/usr/bin/env perl



#Ajout des librairies

use IO::Socket;

use Digest::MD5 qw(md5_hex);

use strict;
use warnings;

#Declaration des variable

my $choixMenu = 0;

my $username = "";

my $password = "";

my $proto = "tcp";

my $host = "localhost";

my $port = 2559;

my $input = "";



my $connection = IO::Socket::INET->new( Proto => $proto,

PeerAddr => $host,

PeerPort => $port)

or die "Impossible de se connecter sur le port $port à l'adresse $host";

$connection->autoflush;

sub readtransmission
{
	local $/ = "!EOT!";
	my $connection = $_[0];
	my $transmission = readline($connection);
	#print "Received : $transmission\n";
	$transmission =~ s/\!EOT\!$//;
	$transmission;
}

sub sendtransmission
{
	local $/ = "!EOT!";
	my $connection = $_[0];
	my $transmission = $_[1];
	#print "sent : $transmission!EOT!\n";
	print $connection "$transmission!EOT!";
}

my $premierMessageServeur = &readtransmission($connection); # readline($connection);
print "$premierMessageServeur\n";

my $messageServeurDemandeNomUtilisateur = &readtransmission($connection); #readline($connection);
while($username eq "")
{
	print "$messageServeurDemandeNomUtilisateur\n";
	chomp($username = <STDIN>); 
}
&sendtransmission($connection, $username);
my $messageServeurDemandeMotDePasse = &readtransmission($connection);
while($password eq "")
{
	print "$messageServeurDemandeMotDePasse\n";
	chomp($password = <STDIN>);
}
my $hashpassword = md5_hex($password);
&sendtransmission($connection, $hashpassword);
my $messageServeurAuthentificationReussi = &readtransmission($connection);
if ($messageServeurAuthentificationReussi eq "OK")
{
	my $messageServeurBienvenue = &readtransmission($connection);
	print "$messageServeurBienvenue\n";
	while (1)
	{
		my $messageServeurMenu = &readtransmission($connection);
		while($choixMenu < 1 || $choixMenu > 5)
		{
			print "$messageServeurMenu\n";
	
			chomp($choixMenu = <STDIN>);
		
		}
		&sendtransmission($connection, $choixMenu);

		if ($choixMenu == 1)
		
		{
			my $peutEnvoyerCourriel = &readtransmission($connection);
			if ($peutEnvoyerCourriel eq "OK")
			{
				#Adresse A:
				my $messageServeurDemandeAdresseA = &readtransmission($connection);
				print "$messageServeurDemandeAdresseA\n";
				chomp(my $adresseA = <STDIN>);
				&sendtransmission($connection, $adresseA);

				#Adresse CC:
				my $messageServeurDemandeAdresseCC = &readtransmission($connection);
				print "$messageServeurDemandeAdresseCC\n";
				chomp(my $adresseCC = <STDIN>);
				&sendtransmission($connection, $adresseCC);

				#Sujet:
				my $messageServeurDemandeSujet = &readtransmission($connection);
				print "$messageServeurDemandeSujet\n";
				chomp(my $sujetCouriel = <STDIN>);
				&sendtransmission($connection, $sujetCouriel);

				#Corps:
				my $messageServeurDemandeCorps = &readtransmission($connection);
				print "$messageServeurDemandeCorps\n";
				chomp(my $corpsCourriel = <STDIN>);
				&sendtransmission($connection, $corpsCourriel);

				#confirmation
				my $messageServeurConfirmationEnvoie = &readtransmission($connection);
				print "$messageServeurConfirmationEnvoie\n";
			}
			else
			{
				print "$peutEnvoyerCourriel";
			}

			print "Appuyez sur Entrée pour continuer...";
			<STDIN>;
			print "\n\n"
		
		} 
		
		elsif ($choixMenu == 2)	
		{
			my $peutConsulterCourriel = &readtransmission($connection);
			if ($peutConsulterCourriel eq "OK")
			{
				my $listeSujetsCourriels = &readtransmission($connection);
				print "Voici la liste des sujets:\n$listeSujetsCourriels\nQuel sujet voulez-vous consulter?\n";
				chomp(my $choixSujetCourriel = <STDIN>);
				&sendtransmission($connection, $choixSujetCourriel);
	
				my $contenuCourriel = &readtransmission($connection);
				print "$contenuCourriel\n";
	
				print "Appuyez sur Entrée pour continuer...";
				<STDIN>;
				print "\n\n"
			}
			else
			{
				print "Aucun message à consulter.\n"
			}
		}
		
		elsif ($choixMenu == 3)
		
		{
			my $statistiques = &readtransmission($connection);
			print $statistiques;
			print "Appuyez sur Entrée pour continuer...";
			<STDIN>;
			print "\n\n"
		}
		
		elsif ($choixMenu == 4)
		
		{
			my $peutConsulterAdmin = &readtransmission($connection);

			if ($peutConsulterAdmin eq "OK")
			{
				my $listeutilisateur = &readtransmission($connection);
				print "Voici la liste des utilisateurs:\n$listeutilisateur\nQuel utilisateur voulez-vous consulter les statistiques?\n";
				chomp(my $choixUtilisateur = <STDIN>);
				&sendtransmission($connection, $choixUtilisateur);

				my $statistiquesutilisateur = &readtransmission($connection);
				print "$statistiquesutilisateur\n";

			}
			else
			{
				print "$peutConsulterAdmin\n";
			}
			print "Appuyez sur Entrée pour continuer...";
			<STDIN>;
			print "\n\n"
		}
		
		elsif ($choixMenu == 5)
		
		{
		
			exit 0;
		
		}
		$choixMenu = 0;
	}
}
else
{
	print "Connection échouée\n";
}

#!/usr/bin/env perl



#Ajout des librairies

use IO::Socket;

use Digest::MD5 qw(md5_hex);



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


$connection->recv(my $premierMessageServeur, 1024);
print "$premierMessageServeur\n";

$connection->recv(my $messageServeurDemandeNomUtilisateur, 1024);
while($username eq "")
{
	print "$messageServeurDemandeNomUtilisateur\n";
	chomp($username = <STDIN>); 
}
$connection->send($username);
$connection->recv(my $messageServeurDemandeMotDePasse, 1024);
while($password eq "")
{
	print "$messageServeurDemandeMotDePasse\n";
	chomp($password = <STDIN>);
}
my $hashpassword = md5_hex($password);
$connection->send($hashpassword);
$connection->recv(my $messageServeurAuthentificationReussi, 1024);
if ($messageServeurAuthentificationReussi eq "OK")
{
	$connection->recv(my $messageServeurBienvenue, 1024);
	print "$messageServeurBienvenue\n";
	while (1)
	{
		$connection->recv(my $messageServeurMenu, 1024);
		while($choixMenu < 1 || $choixMenu > 5)
		{
			print "$messageServeurMenu\n";
	
			chomp($choixMenu = <STDIN>);
		
		}
		$connection->send($choixMenu);

		if ($choixMenu == 1)
		
		{
			#Adresse A:
			$connection->recv(my $messageServeurDemandeAdresseA, 1024);
			print "$messageServeurDemandeAdresseA\n";
			chomp(my $adresseA = <STDIN>);
			$connection->send($adresseA);

			#Adresse CC:
			$connection->recv($messageServeurDemandeAdresseCC, 1024);
			print "$messageServeurDemandeAdresseCC\n";
			chomp(my $adresseCC = <STDIN>);
			$connection->send($adresseCC);

			#Sujet:
			$connection->recv($messageServeurDemandeSujet, 1024);
			print "$messageServeurDemandeSujet\n";
			chomp(my $sujetCouriel = <STDIN>);
			$connection->send($sujetCouriel);

			#Corps:
			$connection->recv($messageServeurDemandeCorps, 1024);
			print "$messageServeurDemandeCorps\n";
			chomp(my $corpsCourriel = <STDIN>);
			$connection->send($corpsCourriel);

			#confirmation
			$connection->recv($messageServeurConfirmationEnvoie, 1024);
			print "$messageServeurConfirmationEnvoie\n";

			print "Appuyer sur Entrée pour continuer...";
			<STDIN>;
			print "\n\n"
		
		} 
		
		elsif ($choixMenu == 2)	
		{
			$connection->recv(my $peutConsulterCourriel, 1024);
			if ($peutConsulterCourriel eq "OK")
			{
				$connection->recv(my $listeSujetsCourriels, 1048576);
				print "Voici la liste des sujets:\n $listeSujetsCourriels\n Quel sujet voulez-vous consulter?\n";
				chomp(my $choixSujetCourriel = <STDIN>);
				$connection->send($choixSujetCourriel);
	
				$connection->recv(my $contenuCourriel, 1048576);
				print "$contenuCourriel\n";
	
				print "Appuyer sur Entrée pour continuer...";
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
		
		}
		
		elsif ($choixMenu == 4)
		
		{
		
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

  
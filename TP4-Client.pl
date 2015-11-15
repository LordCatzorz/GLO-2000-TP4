#!/usr/bin/env perl

#Ajout des librairies
use IO::Socket;
use Digest::MD5 qw(md5_hex);

#Declaration des variable
my $choice = 0;
my $username = "";
my $password = "";
my $proto = "tcp";
my $host = "localhost";
my $port = 2554;
my $input = "";

my $connection = IO::Socket::INET->new( Proto => $proto,
PeerAddr => $host,
PeerPort => $port)
or die "Impossible de se connecter sur le port $port à l'adresse $host";

while ($ligne ne "quit\n")
{
	$input = <$connection>;
	print $input;
	while($username eq "")
	{
		print "Veuillez entrer votre nom d'utilisateur:\n";
		$username = <STDIN>; 
		print $connection $username;
		$input = <$connection>;
		print $input;
	}

	while($password eq "")
	{
		print "Veuillez entrer votre mot de passe:\n";
		$password = <STDIN>;
		print $connection $password;
		$input = <$connection>;
		print $input;
	}

	while($choice < 1 || $choice > 5)
	{
		print "Menu\n1. Envoie de courriels \n2. Consultation de courriels\n3. Statistiques\n4. Mode administrateur\n5. Quitter \n";
		$choice = <STDIN>;
		chomp($choice);
		print $choice;
	}

	if ($choice == 1)
	{
		#Choix 1 
		print "choix 1"
		print "Quelle est l'adresse de destination:\n";
		my $destAdr = <STDIN>;
		print "Quelle est l'adresse en copie conforme:\n";
		my $ccAdr = <STDIN>;
		print "Quel est le sujet:\n";
		my $subject = <STDIN>;
		print "Quel est le corps du message:\n";
		my $body = <STDIN>;
	} 
	elsif ($choice == 2)
	{
		#Choix 2 
		print "choix 2"
		print "Quel numero:\n";
		my $number = <STDIN>;
	}
	elsif ($choice == 3)
	{
		#Choix 3 
		print "choix 3"
	}
	elsif ($choice == 4)
	{
		#Choix 4
		print "choix 4"
	}
	elsif ($choice == 5)
	{
		exit 0;
	}
}
  
   

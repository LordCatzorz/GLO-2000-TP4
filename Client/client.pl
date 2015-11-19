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

my $port = 2559;

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

		#print "Veuillez entrer votre nom d'utilisateur:\n";

		$input = <$connection>;

		print $input;
		$username = <STDIN>; 

	}

	print $connection $username;



	while($password eq "")

	{

		#print "Veuillez entrer votre mot de passe:\n";
		$input = <$connection>;

		print $input;

		$password = <STDIN>;

	}
	print md5_hex($password);
	my $hashpassword = md5_hex($password);

	print $connection $hashpassword;
	$input = <$connection>;

	print $input;



	while($choice < 1 || $choice > 5)

	{

		print "Menu\n1. Envoie de courriels \n2. Consultation de courriels\n3. Statistiques\n4. Mode administrateur\n5. Quitter \n";

		$choice = <STDIN>;

		chomp($choice);
		print $connection $choice;

	}



	if ($choice == 1)

	{

		print "Quelle est l'adresse de destination:\n";

		my $destAdr = <STDIN>;
		#print $connection $destAdr;

		print "Quelle est l'adresse en copie conforme:\n";

		my $ccAdr = <STDIN>;
		#print $connection $ccAdr;

		print "Quel est le sujet:\n";

		my $subject = <STDIN>;
		#print $connection $subject;

		print "Quel est le corps du message:\n";

		my $body = <STDIN>;
		#print $connection $body

	} 

	elsif ($choice == 2)

	{

		print "Quel numero:\n";

		my $number = <STDIN>;

	}

	elsif ($choice == 3)

	{

	}

	elsif ($choice == 4)

	{

	}

	elsif ($choice == 5)

	{

		exit 0;

	}

}

  

   
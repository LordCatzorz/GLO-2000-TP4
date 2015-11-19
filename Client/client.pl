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



#while ($ligne ne "quit\n")

#{

	#chomp($input = <$connection>);
	$connection->recv($input, 1024);
	print "$input\n";
	#chomp($input = <$connection>);
	$connection->recv($input, 1024);
	

	while($username eq "")
	{
		print "$input\n";
		chomp($username = <STDIN>); 
		print "username : $username\n";

	}
	print "Envoie au serveur 1\n";
	#print $connection $username;
	$connection->send($username);

	#chomp($input = <$connection>);
	$connection->recv($input, 1024);
	while($password eq "")
	{
		print "debut password\n";
		print "$input\n";
		
		chomp($password = <STDIN>);
		print "Password : $password\n";
	}
	my $hashpassword = md5_hex($password);

	print "hashpassword : $hashpassword\n";
	print "Envoie au serveur 2\n";

	#print $connection $hashpassword;
	
	$connection->send($hashpassword);

	$connection->recv($input, 1024);
	if ($input eq "OK")
	{
		$connection->recv($input, 1024);
		print "$input\n";

		
		$connection->recv($input, 1024);
		while($choice < 1 || $choice > 5)
		
		{
			#print "menu";
			#print "$input\n";#menu
			#print "Menu\n1. Envoie de courriels \n2. Consultation de courriels\n3. Statistiques\n4. Mode administrateur\n5. Quitter \n";
		
			print "$input\n";
	
			chomp($choice = <STDIN>);
			print "choice : $choice\n";
		
		}
	
		print "Envoie au serveur 3\n";
		$connection->send($choice);
		#shutdown($connection, 1);
		
		
		if ($choice == 1)
		
		{
			#Adresse A:
			$connection->recv($input, 1024);
			print "$input\n";
			chomp($input = <STDIN>);
			$connection->send($input);

			#Adresse CC:
			$connection->recv($input, 1024);
			print "$input\n";
			chomp($input = <STDIN>);
			$connection->send($input);

			#Sujet:
			$connection->recv($input, 1024);
			print "$input\n";
			chomp($input = <STDIN>);
			$connection->send($input);

			#Corps:
			$connection->recv($input, 1024);
			print "$input\n";
			chomp($input = <STDIN>);
			$connection->send($input);
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
	else
	{
		print "Connection échouée\n";
	}

#}

  

   
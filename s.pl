use IO::Socket;

my $socket= IO::Socket::INET->new( Proto => "tcp",
								   LocalPort => 2559,
								   Listen => SOMAXCONN,
								   Reuse => 1);

while(1)
{
	print "Waiting for a client\n";
	my $client = $socket->accept();
	$client->send("Hello, please connect yourself");
	$client->flush;
	$client->send("Username:");
	$client->flush;
	$client->recv(my $username, 1024);
	$client->flush;
	$client->send("Password:");
	$client->flush;
	$client->recv(my $cipheredpassword, 1024);
	$client->flush;
	$client->send("Thank you, Goodbye.");
	$client->flush;
	$client->close();
	print "Connection closed\n";
}
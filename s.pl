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
	$client->send("Username:");
	$client->recv(my $username, 1024);
	$client->send("Password:");
	$client->recv(my $cipheredpassword, 1024);
	$client->send("Thank you, Goodbye.");
	$client->close();
	print "Connection closed\n";
}
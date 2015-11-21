use IO::Socket;
use Digest::MD5 qw(md5_hex);

my $username = "";
my $password = "";

my $server = IO::Socket::INET->new( Proto => "tcp",
										PeerAddr => "localhost",
										PeerPort => 2559);

$server->recv(my $firstServerMessage, 1024);
$server->flush;
print "$firstServerMessage\n";
$server->recv(my $serverAskUsernameMessage, 1024);
$server->flush;
while($username eq "")
{
	print "$serverAskUsernameMessage\n";
	chomp($username = <STDIN>); 
}
$server->send($username);
$server->flush;
$server->recv(my $serverAskPasswordMessage, 1024);
$server->flush;
while($password eq "")
{
	print "$serverAskPasswordMessage\n";
	chomp($password = <STDIN>);
}
my $hashedPassword = md5_hex($password);
$server->send($hashedPassword);
$server->flush;
$server->recv(my $lastServerMessage, 1024);
$server->flush;
print $lastServerMessage;
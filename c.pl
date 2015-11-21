use IO::Socket;
use Digest::MD5 qw(md5_hex);

my $username = "";
my $password = "";

my $server = IO::Socket::INET->new( Proto => "tcp",
										PeerAddr => "localhost",
										PeerPort => 2559);

$server->recv(my $firstServerMessage, 1024);
print "$firstServerMessage\n";
$server->recv(my $serverAskUsernameMessage, 1024);
while($username eq "")
{
	print "begin while\n";
	print "$serverAskUsernameMessage\n";
	chomp($username = <STDIN>); 
	print "end while\n";
}
	print "bedin send \n";
$server->send($username);
	print "end send \n";
$server->recv(my $serverAskPasswordMessage, 1024);
	print "end recv \n";
while($password eq "")
{
	print "$serverAskPasswordMessage\n";
	chomp($password = <STDIN>);
}
my $hashedPassword = md5_hex($password);
$server->send($hashedPassword);
$server->recv(my $lastServerMessage, 1024);
print $lastServerMessage;
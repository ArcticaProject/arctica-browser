#!/usr/bin/perl -X -T

use strict;
use Data::Dumper;
use Arctica::Core::eventInit qw(genARandom BugOUT);
use Arctica::Core::JABus::Socket;
use POSIX qw(mkfifo);
use Gtk3 -init;
use Glib;
use Glib::Object::Introspection;
use Glib qw(TRUE FALSE);

use Arctica::Browser::ToolBar;
use Arctica::Browser::WebView;
use Arctica::Browser::Proxy;

Glib::Object::Introspection->setup(
	basename => "GdkX11",
	version => "3.0",
	package => "Gtk3::Gdk");

my $proxy = Arctica::Browser::Proxy->new;

my $gnx_xid = `/usr/bin/xwininfo -root -all|/bin/grep NXAgent`;
if ($gnx_xid =~ /^\s*(0x[0-9a-f]*)\s.*/) {
        $gnx_xid = $1;
} else {
        die;
}


my $lastcontact = (time + 5);

my $ACO = Arctica::Core::eventInit->new({
	app_name=>'forked-overlay-test',
	app_class =>'amoduletester',
	app_version=>'0.0.1.1'});

my $app_id = @ARGV[0];
my $ttid = @ARGV[1];
my $sock_id;

if (@ARGV[2] =~ /^([a-zA-Z0-9]*)$/) {
	$sock_id = $1;
	BugOUT(8,"SOC:\t$sock_id");
} else {die("YOU SOCK!");}




my $TeKi = Arctica::Core::JABus::Socket->new($ACO,{
	type	=>	"unix",
	destination =>	"local", # FIX ME (change to remote!!!)
	is_client => 1,
	connect_to => $sock_id,
	handle_in_dispatch => {
			chtstate => sub {\&chtargetstate(@_)},
#			srvcneg => sub {$TeKiClient->c2s_service_neg(@_)},
#			appctrl => \&teki_client2s_appctrl,
	},
	hooks => {
		on_ready => sub {my_ready($app_id,$ttid);},
		on_client_errhup => sub {die("\tLOST CONN!\n");},
	},
});

my $timeout = Glib::Timeout->add(100, sub {
#print "\tTime:\t",time,"\n\tLast:\t$lastcontact\n";
	if ($lastcontact < (time-2)) {
		die("We're an orphan?");
	}
	return 1;
});


my $window = Gtk3::Window->new('popup');
$window->set_default_size(80, 60);
$window->set_title('Browser');
$window->signal_connect(destroy => sub { Gtk3->main_quit() });

my $toolbar = Arctica::Browser::ToolBar->new;
my $webview = Arctica::Browser::WebView->new($toolbar);

my $vbox = Gtk3::Box->new( 'vertical', 0);
$vbox->set_border_width(0);
$vbox->pack_start($toolbar->return_toolbar,FALSE,FALSE,0);
$vbox->pack_start($webview->return_webview,TRUE,TRUE,0);
$window->add($vbox);

$window->show_all();
$window->unmap();

system("/usr/bin/xdotool","windowreparent",$window->get_window->get_xid,$gnx_xid);


$ACO->{'Glib'}{'MainLoop'}->run;


sub chtargetstate {
	my $data = $_[0];
	$lastcontact = time();
	warn(Dumper($data));
	my $x = $data->{'apx'};
	my $y = $data->{'apy'};
#warn("CH:\t$x,$y\t$data->{'w'} * $data->{'h'}	[$data->{'alive'}]");

	if ($data->{'w'} and $data->{'h'}) {
		$window->resize($data->{'w'},$data->{'h'});

	}

	if ((defined $x) and (defined $y)) {
		$window->move($x,$y);
	}


	if ($data->{'visible'} eq 1) {
			$window->map();
	} else {
		$window->unmap();
	}
}

sub my_ready {
	BugOUT(8,"MY READY?");
	my $app_id = $_[0];
	my $ttid = $_[1];
	$TeKi->client_send('treg',{
				app_id => $app_id,
				ttid => $ttid,
	});
}

sub daemonize {
	fork and exit;
	POSIX::setsid();
	fork and exit;
	umask 0;
	chdir '/';
	close STDIN;
	close STDOUT;
	close STDERR;
}

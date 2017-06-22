################################################################################
#          _____ _
#         |_   _| |_  ___
#           | | | ' \/ -_)
#           |_| |_||_\___|
#                   _   _             ____            _           _
#    / \   _ __ ___| |_(_) ___ __ _  |  _ \ _ __ ___ (_) ___  ___| |_
#   / _ \ | '__/ __| __| |/ __/ _` | | |_) | '__/ _ \| |/ _ \/ __| __|
#  / ___ \| | | (__| |_| | (_| (_| | |  __/| | | (_) | |  __/ (__| |_
# /_/   \_\_|  \___|\__|_|\___\__,_| |_|   |_|  \___// |\___|\___|\__|
#                                                  |__/
#          The Arctica Modular Remote Computing Framework
#
################################################################################
#
# Copyright (C) 2015-2016 The Arctica Project
# http://http://arctica-project.org/
#
# This code is dual licensed: strictly GPL-2 or AGPL-3+
#
# GPL-2
# -----
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
# Free Software Foundation, Inc.,
#
# 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
#
# AGPL-3+
# -------
# This programm is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This programm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
#
# Copyright (C) 2015-2016 Guangzhou Nianguan Electronics Technology Co.Ltd.
#                         <opensource@gznianguan.com>
# Copyright (C) 2015-2016 Mike Gabriel <mike.gabriel@das-netzwerkteam.de>
#
################################################################################
package Arctica::Browser::Overlay::WebView;
use strict;
use Gtk3;
use Glib 'TRUE', 'FALSE';
use Gtk3::WebKit;
use Data::Dumper;
# Be very selective about what (if any) gets exported by default:
our @EXPORT = qw();
# And be mindful of what we let the caller request, too:
our @EXPORT_OK = qw(  );

sub new {
	my $class_name = $_[0];
	my $related_toolbar = $_[1];

	my $self = {
		isArctica => 1,
		aobject_name => "browser_webview",
	};
	bless($self, $class_name);

	if ($related_toolbar) {
		if ($related_toolbar->{'aobject_name'} eq "browser_toolbar") {
			$self->{'toolbar'} = $related_toolbar;
			$related_toolbar->{'webview'} = $self;
		} else {
			die("Thats not a toolbar you're trying to pass of as one, is it?");
		}
	} else {
		$related_toolbar = FALSE;
	}


	$self->_gen_webview_main;

	return $self;
}


sub return_webview {
	my $self = $_[0];
	if ($self->{'_gtk'}{'webview'}{'main_container'}) {
		return $self->{'_gtk'}{'webview'}{'main_container'};
	} else {
		die("Can't return a webview that does not exist, can we?");
	}
}

sub _gen_webview_main {
	my $self = $_[0];

	$self->{'_gtk'}{'webview'}{'main_container'} = Gtk3::Overlay->new();

	$self->{'_gtk'}{'webview'}{'thewebview'} = Gtk3::WebKit::WebView->new();
	$self->{'_gtk'}{'webview'}{'thewebview'}->load_uri("http://bing.com/");#
	$self->{'_gtk'}{'webview'}{'scroller'} = Gtk3::ScrolledWindow->new();
	$self->{'_gtk'}{'webview'}{'scroller'}->add($self->{'_gtk'}{'webview'}{'thewebview'});
	$self->{'_gtk'}{'webview'}{'main_container'}->add($self->{'_gtk'}{'webview'}{'scroller'});

	$self->{'_gtk'}{'webview'}{'bottom_overlay_text'} = Gtk3::Label->new();
	$self->{'_gtk'}{'webview'}{'bottom_overlay_text'}->set_halign('start');
	$self->{'_gtk'}{'webview'}{'bottom_overlay_text'}->set_valign('end');	
	$self->{'_gtk'}{'webview'}{'main_container'}->add_overlay($self->{'_gtk'}{'webview'}{'bottom_overlay_text'});


	$self->{'_gtk'}{'webview'}{'thewebview'}->signal_connect( 'hovering-over-link' => sub {$self->_sigfunc_webview_hover_over_link($_[2]);}, undef );
	$self->{'_gtk'}{'webview'}{'thewebview'}->signal_connect( 'notify::load-status' => sub {$self->_sigfunc_webview_notify_load_status;}, undef );
	$self->{'_gtk'}{'webview'}{'thewebview'}->signal_connect( 'notify::progress' => sub {$self->_sigfunc_webview_notify_progress;}, undef );
#	$self->{'_gtk'}{'webview'}{'thewebview'}->signal_connect( 'notify::title' => sub {} , undef );

}

sub ext_sigfunc {
	my $self = $_[0];
	my $func = $_[1];
	my $func_data = $_[2];
#	print "WEBVIEW SIGFUNC:\t$_[1]\n";
#	print Dumper($_[2]);
	if ($func eq "reload") {
		$self->{'_gtk'}{'webview'}{'thewebview'}->reload();
	} elsif ($func eq "stop") {
		$self->{'_gtk'}{'webview'}{'thewebview'}->stop_loading();
	} elsif ($func eq "load_uri") {
		$self->{'_gtk'}{'webview'}{'thewebview'}->load_uri($func_data);
	} elsif ($func eq "history_back") {
		$self->{'_gtk'}{'webview'}{'thewebview'}->go_back;
	} elsif ($func eq "history_forward") {
		$self->{'_gtk'}{'webview'}{'thewebview'}->go_forward;
	} 
}

sub _sigfunc_webview_notify_load_status {
	my $self = $_[0];
	my $status = $self->{'_gtk'}{'webview'}{'thewebview'}->get('load_status');
	if ($status eq 'committed') {
		my $uri = $self->{'_gtk'}{'webview'}{'thewebview'}->get_uri();
#		if ($uri) {print "URI:\t$uri\n";}
		$self->{'toolbar'}->ext_sigfunc('load_committed',$uri)
	} elsif ($status eq 'finished') {
		my $uri = $self->{'_gtk'}{'webview'}{'thewebview'}->get_uri();
		$self->{'toolbar'}->ext_sigfunc('load_finished',$uri)
	} else {
#		print "WTF LS:\t$status\n";
	}
}

sub _sigfunc_webview_notify_progress {
	my $self = $_[0];
	my $progress = $self->{'_gtk'}{'webview'}{'thewebview'}->get('progress');
	if ($progress) {
		$self->{'toolbar'}->ext_sigfunc('load_progress',sprintf("%.2f", $progress));
	} 
}

sub _sigfunc_webview_hover_over_link {
	my $self = $_[0];
	my $link = $_[1];
	if ($link) {
		$self->{'_gtk'}{'webview'}{'bottom_overlay_text'}->set_text($link);
	} else {
		$self->{'_gtk'}{'webview'}{'bottom_overlay_text'}->set_text('');
	}
}

1;

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
package Arctica::Browser::Overlay::ToolBar;
use strict;
use Gtk3;
use Glib 'TRUE', 'FALSE';
use Data::Dumper;
# Be very selective about what (if any) gets exported by default:
our @EXPORT = qw();
# And be mindful of what we let the caller request, too:
our @EXPORT_OK = qw(  );

sub new {
	my $class_name = $_[0];
#	$arctica_core_object = $_[1];
	my $self = {
		isArctica => 1,
		aobject_name => "browser_toolbar",
		webview => FALSE,
	};
	bless($self, $class_name);

	$self->_gen_toolbar_main;

	return $self;
}


sub return_toolbar {
	my $self = $_[0];
	if ($self->{'_gtk'}{'toolbar'}{'main'}) {
		return $self->{'_gtk'}{'toolbar'}{'main'};
	} else {
		die("Can't return a toolbar that does not exist, can we?");
	}
}

sub _gen_toolbar_main {
	my $self = $_[0];
        $self->{'_gtk'}{'toolbar'}{'main'} = Gtk3::Toolbar->new;
	$self->{'_gtk'}{'toolbar'}{'main'}->set_icon_size('small-toolbar');
	$self->{'_gtk'}{'toolbar'}{'main'}->set_show_arrow(FALSE);
        $self->{'_gtk'}{'toolbar'}{'main'}->set_orientation('GTK_ORIENTATION_HORIZONTAL');

	$self->_gen_history_buttons($self->{'_gtk'}{'toolbar'}{'main'});

	$self->{'_gtk'}{'toolbar'}{'main'}->insert(Gtk3::SeparatorToolItem->new ,-1 );

	$self->_gen_url_entry_area($self->{'_gtk'}{'toolbar'}{'main'});

	$self->{'_gtk'}{'urlentry'}{'url_entry'}->grab_focus;
}

sub _gen_url_entry_area {
	my $self = $_[0];
	my $the_toolbar = $_[1];
	$self->{'_gtk'}{'urlentry'}{'containerbox'} = Gtk3::ToolItem->new();
	$self->{'_gtk'}{'urlentry'}{'containerbox'}->set_expand(1);

	$self->{'_gtk'}{'urlentry'}{'url_entry'} = Gtk3::Entry->new();
	$self->{'_gtk'}{'urlentry'}{'url_entry'}->signal_connect( "activate" => sub {$self->_sigfunc_url_entry_activate;}, undef );
	$self->{'_gtk'}{'urlentry'}{'url_entry'}->signal_connect( 'icon-press' => sub {$self->_sigfunc_url_entry_icon_press(@_)} );

	$self->{'_gtk'}{'urlentry'}{'containerbox'}->add($self->{'_gtk'}{'urlentry'}{'url_entry'});

	$the_toolbar->insert($self->{'_gtk'}{'urlentry'}{'containerbox'}, -1);
}

sub _gen_history_buttons {
	my $self = $_[0];
	my $the_toolbar = $_[1];
	$self->{'_gtk'}{'history'}{'btn_back'} = Gtk3::ToolButton->new_from_stock('gtk-go-back');
	$self->{'_gtk'}{'history'}{'btn_back'}->signal_connect( "clicked" => sub {$self->_sigfunc_history_back;}, undef );
	$the_toolbar->insert($self->{'_gtk'}{'history'}{'btn_back'}, -1);

	$self->{'_gtk'}{'history'}{'btn_forward'} = Gtk3::ToolButton->new_from_stock('gtk-go-forward');
	$self->{'_gtk'}{'history'}{'btn_forward'}->signal_connect( "clicked" => sub {$self->_sigfunc_history_forward;}, undef );
	$the_toolbar->insert($self->{'_gtk'}{'history'}{'btn_forward'}, -1);
}

sub ext_sigfunc {
	my $self = $_[0];
	my $func = $_[1];
	my $func_data = $_[2];
#	print "TOOLBAR SIGFUNC:\t$_[1]\n";
#	print Dumper($_[2]);
	if ($func eq "load_progress") {
		$self->_url_entry_progress_update($func_data);
	} elsif ($func eq "load_committed") {
		$self->_url_entry_status_change($func,$func_data);
	} elsif ($func eq "load_finished") {
		$self->_url_entry_status_change($func,$func_data);
	}
}

sub _url_entry_status_change {
	my $self = $_[0];
	my $state = $_[1];
	my $uri = $_[2];
	if ($state eq "load_committed") {
		$self->{'_gtk'}{'urlentry'}{'_status'} = "committed";
		$self->{'_gtk'}{'urlentry'}{'url_entry'}->set_text($uri);
		$self->{'_gtk'}{'urlentry'}{'url_entry'}->set_icon_from_stock('secondary','gtk-stop');
	} elsif ($state eq "load_finished") {
		$self->{'_gtk'}{'urlentry'}{'_status'} = "finished";
		$self->{'_gtk'}{'urlentry'}{'url_entry'}->set_text($uri);
		$self->{'_gtk'}{'urlentry'}{'url_entry'}->set_icon_from_stock('secondary','gtk-refresh');
	}
}


sub _url_entry_progress_update {
	my $self = $_[0];
	my $load_fraction = $_[1];
	if ($self->{'_gtk'}{'urlentry'}{'url_entry'}) {
		if ($load_fraction < 1) {
			$self->{'_gtk'}{'urlentry'}{'url_entry'}->set_progress_fraction($load_fraction);
		} else {
			$self->{'_gtk'}{'urlentry'}{'url_entry'}->set_progress_fraction(0);
		}
	}
}

sub _sigfunc_url_entry_icon_press {
	my $self = $_[0];
	my $which_icon = $_[2];
	if ($which_icon eq "secondary") {
		if ($self->{'_gtk'}{'urlentry'}{'_status'} eq "commited") {
			if ($self->{'webview'}) {
				$self->{'webview'}->ext_sigfunc('stop');
			}
		} elsif ($self->{'_gtk'}{'urlentry'}{'_status'} eq "finished") {
			if ($self->{'webview'}) {
				$self->{'webview'}->ext_sigfunc('reload');
			}
		}
	}
}

sub _sigfunc_url_entry_activate {
	my $self = $_[0];
	if ($self->{'webview'}) {
 		my $uri = $self->{'_gtk'}{'urlentry'}{'url_entry'}->get_text;
		unless ($uri =~ /^[a-z]*\:\/\/.*/) {# do better URL validation here!
			$uri = "http://$uri";
		}
		$self->{'webview'}->ext_sigfunc('load_uri',$uri);
	} else {
		warn("No WebView attached to this toolbar?");
	}
}

sub _sigfunc_history_back {
	my $self = $_[0];
	if ($self->{'webview'}) {
		$self->{'webview'}->ext_sigfunc('history_back');
	} else {
		warn("No WebView attached to this toolbar?");
	}
}

sub _sigfunc_history_forward {
	my $self = $_[0];
	if ($self->{'webview'}) {
		$self->{'webview'}->ext_sigfunc('history_forward');
	} else {
		warn("No WebView attached to this toolbar?");
	}
}


1;

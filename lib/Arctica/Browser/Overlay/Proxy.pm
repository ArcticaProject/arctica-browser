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
package Arctica::Browser::Overlay::Proxy;
use strict;
use Glib 'TRUE', 'FALSE';
# Be very selective about what (if any) gets exported by default:
our @EXPORT = qw();
# And be mindful of what we let the caller request, too:
our @EXPORT_OK = qw(  );

sub new {
	my $class_name = $_[0];
#	$arctica_core_object = $_[1];
	my $self = {
		isArctica => 1,
		aobject_name => "browser_proxy",
		webview => FALSE,
	};
	bless($self, $class_name);

	$self->_set_proxy(8888);

	return $self;
}

sub _set_proxy {
	my $self = $_[0];
	my $port = $_[1];
	my $username = $_[2];
	my $password = $_[3];
	my $hostname = "localhost";
	my $auth_string;
	if ($username and $password) {
		$auth_string = "$username:$password\@";
	}
	my $proxy_string = "http://$auth_string$hostname:$port";
	$ENV{'HTTP_PROXY'} = $proxy_string;
	$ENV{'http_proxy'} = $proxy_string;
	$ENV{'HTTPS_PROXY'} = $proxy_string;
	$ENV{'https_proxy'} = $proxy_string;
	
}



1;

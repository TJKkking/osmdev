#!/usr/bin/env python3
##
# Copyright 2020 Canonical Ltd.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
##

import sys

sys.path.append("lib")

from charms.osm.sshproxy import SSHProxyCharm
from ops.main import main

class MySSHProxyCharm(SSHProxyCharm):

    def __init__(self, framework, key):
        super().__init__(framework, key)

        # Listen to charm events
        self.framework.observe(self.on.config_changed, self.on_config_changed)
        self.framework.observe(self.on.install, self.on_install)
        self.framework.observe(self.on.start, self.on_start)

        # Listen to the touch action event
        self.framework.observe(self.on.touch_action, self.on_touch_action)

    def on_config_changed(self, event):
        """Handle changes in configuration"""
        super().on_config_changed(event)

    def on_install(self, event):
        """Called when the charm is being installed"""
        super().on_install(event)

    def on_start(self, event):
        """Called when the charm is being started"""
        super().on_start(event)

    def on_touch_action(self, event):
        """Touch a file."""

        if self.model.unit.is_leader():
            filename = event.params["filename"]
            proxy = self.get_ssh_proxy()
            stdout, stderr = proxy.run("touch {}".format(filename))
            event.set_results({"output": stdout})
        else:
            event.fail("Unit is not leader")
            return

if __name__ == "__main__":
    main(MySSHProxyCharm)


# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright 2012 OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

"""Main entry point into the Identity service."""

from keystone.common import dependency
from keystone.common import manager
from keystone import config
from keystone import exception
from keystone.openstack.common import log as logging


CONF = config.CONF

LOG = logging.getLogger(__name__)


@dependency.provider('dtrust_api')
class Manager(manager.Manager):
    """Default pivot point for the DTrust backend.

    See :mod:`keystone.common.manager.Manager` for more details on how this
    dynamically calls the backend.

    """

    def __init__(self):
        super(Manager, self).__init__(CONF.dtrust.driver)


class Driver(object):
    def create_dtrust(self, dtrust_id, trust, roles):
        """Create a new dtrust.

        :returns: a new dtrust object
        """
        raise exception.NotImplemented()

    def get_dtrust(self, dtrust_id):
        raise exception.NotImplemented()

    def list_dtrusts(self):
        raise exception.NotImplemented()

    def list_dtrusts_for_trustee(self, trustee):
        raise exception.NotImplemented()

    def list_dtrusts_for_trustor(self, trustor):
        raise exception.NotImplemented()

    def delete_dtrust(self, trust_id):
        raise exception.NotImplemented()

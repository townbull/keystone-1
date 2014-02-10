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
"""WSGI Routers for the Identity service."""

from keystone.dtrust import controllers


def append_v3_routers(mapper, routers):
    dtrust_controller = controllers.DTrustV3()

    mapper.connect('/OS-DOMAIN-TRUST/trusts',
                   controller=dtrust_controller,
                   action='create_dtrust',
                   conditions=dict(method=['POST']))

    mapper.connect('/OS-DOMAIN-TRUST/trusts',
                   controller=dtrust_controller,
                   action='list_dtrusts',
                   conditions=dict(method=['GET']))

    mapper.connect('/OS-DOMAIN-TRUST/trusts/{trust_id}',
                   controller=dtrust_controller,
                   action='delete_dtrust',
                   conditions=dict(method=['DELETE']))

    mapper.connect('/OS-DOMAIN-TRUST/trusts/{trust_id}',
                   controller=dtrust_controller,
                   action='get_dtrust',
                   conditions=dict(method=['GET']))

    """
    mapper.connect('/OS-DOMAIN-TRUST/trusts/{trust_id}/roles',
                   controller=dtrust_controller,
                   action='list_roles_for_dtrust',
                   conditions=dict(method=['GET']))

    mapper.connect('/OS-DOMAIN-TRUST/trusts/{trust_id}/roles/{role_id}',
                   controller=dtrust_controller,
                   action='check_role_for_trust',
                   conditions=dict(method=['HEAD']))

    mapper.connect('/OS-DOMAIN-TRUST/trusts/{trust_id}/roles/{role_id}',
                   controller=dtrust_controller,
                   action='get_role_for_trust',
                   conditions=dict(method=['GET']))
    """
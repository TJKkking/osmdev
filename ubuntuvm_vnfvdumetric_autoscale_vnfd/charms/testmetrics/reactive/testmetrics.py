from charmhelpers.core.hookenv import (
    action_get,
    action_fail,
    action_set,
    config,
    status_set,
)

from charms.reactive import (
    remove_state as remove_flag,
    set_state as set_flag,
    when,
    when_not,
)
import charms.sshproxy
from subprocess import (
    Popen,
    CalledProcessError,
    PIPE,
)

import time

@when_not('testmetrics.installed')
def install_testmetrics():
    # Do your setup here.
    #
    # If your charm has other dependencies before it can install,
    # add those as @when() clauses above., or as additional @when()
    # decorated handlers below
    #
    # See the following for information about reactive charms:
    #
    #  * https://jujucharms.com/docs/devel/developer-getting-started
    #  * https://github.com/juju-solutions/layer-basic#overview
    #
    status_set('blocked', 'Waiting for SSH credentials.')
    set_flag('testmetrics.installed')

# say-hello sample action
# two when clauses work like an AND
@when('testmetrics.installed')
@when('actions.say-hello')
def say_hello():
    err = ''
    ## Gets the name parameter that the descriptor passed, otherwise the defined by default in actions.yaml
    param1 = "Hello " + action_get("name")
    try:
        # Put the code here that you want to execute, it includes parameters
        # Parameters should be defined in both actions.yaml and the VNF descriptor
        ## Define the command to run
        cmd = "sudo wall -n " + param1
        ## Run the command through SSH
        result, err = charms.sshproxy._run(cmd)
    except:
        # In case it fails, throw an exception
        action_fail('command failed:' + err)
    else:
        # In case it suceeds, return the output
        action_set({'output': result})
    finally:
        # Finally, end the action by removing the flag
        remove_flag('actions.say-hello')

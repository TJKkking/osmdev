# layer-metrics

Reactive charm layer supporting Juju metrics collection.

## Usage

Add this layer to your charm's `layer.yaml`:

```
includes:
 - layer:metrics
```

## Collecting metrics

Declare metrics in your charm's `metrics.yaml`. For example:

```
metrics:
  users:
    type: gauge
    description: number of users
    command: scripts/count_users.py --global
  transactions:
    type: absolute
    description: number of new transactions since last measurement
    command: scripts/stats.py | awk '{print $3}'
```

### Supported metric types

`type: gauge` metrics are values that measure some quantity at the time of capture.

`type: absolute` metrics report the amount added since last time.

### The juju-units metric

The built-in Juju metric `juju-units` sends a `"1"` value for each Juju unit.
This is useful for deriving units- or applications- per time-period. To enable
it, simply declare:

```
metrics:
  juju-units:
```

without any attributes.

### Collection commands

`command:` specifies a shell command to execute, which takes a reading of the
metric. The command must write a single, postive numeric string to stdout.
This string may be an integer (like `15`) or a decimal (like `3.1415`).

The current working directory for the command is the charm directory.

#### Caveat

Metrics may be collected concurrently with Juju hook execution, so the Juju
hook context is not available. Most hook tools, such as `config-get`,
`config-set`, and wrappers such as `charmhelpers.core.hookenv` cannot be used
from within the collection commands.

`charmhelpers.core.unitdata` _is_ available, and is the preferred means of
coordination between reactive handler functions or charm hooks, and the metric
collection context.

#!/bin/bash

# try to use native netcat where it exists as sometimes the docker version doesn't have 
# permissions to do host networking. If you have disabled user namespace remapping and don't 
# have `nc` installed this will still silently fail
NC=nc
if ! which -s "$NC" ; then 
  NC="docker run -i --rm --network=host subfuzion/netcat"
fi

function reportToDatadog() {
  local metric_name=$1
  local metric_value=$2
  local metric_type=$3
  local tags=$4

  DD_HOST=${BUILDKITE_PLUGIN_DATADOG_STATS_DOGSTATSD_HOST:-localhost}
  DD_PORT=${BUILDKITE_PLUGIN_DATADOG_STATS_DOGSTATSD_PORT:-8125}

  echo "Reporting ${metric_name} with value=${metric_value}, type=${metric_type}, tags=${tags}"
  echo "Sending to ${DD_HOST}:${DD_PORT} using command '${NC}'..."
  echo -n "${metric_name}:${metric_value}|${metric_type}|#${tags}" | $NC "${DD_HOST}" "${DD_PORT}"
}

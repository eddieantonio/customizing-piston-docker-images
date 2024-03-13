# Assumes that you have already:
# - cloned Piston
# - installed the Piston CLI
# - spun up a temporary Piston container
# - used the Piston API to install packages interactively
# - these packages are now in ./data/piston/packages
FROM ghcr.io/eddieantonio/piston:20231101@sha256:6500f2af69ce18fe16ca9a0ba7b0ea895366fc0efa46860c03d1d3c8a6cd270d as packages-only
COPY ./data/piston/packages /piston/packages
# Tag and push the above image for faster customizations in the future

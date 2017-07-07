#!/bin/sh

logit "\n"
info "6 - Docker Security Operations"

# 6.1
check_6_1="6.1  - Avoid image sprawl"
images=$(docker images -q | sort -u | wc -l | awk '{print $1}')
active_images=0

for c in $(docker inspect -f "{{.Image}}" $(docker ps -qa) 2>/dev/null); do
  if docker images --no-trunc -a | grep "$c" > /dev/null ; then
    active_images=$(( active_images += 1 ))
  fi
done

  info "$check_6_1"
  info "     * There are currently: $images images"

if [ "$active_images" -lt "$((images / 2))" ]; then
  info "     * Only $active_images out of $images are in use"
fi

# 6.2
check_6_2="6.2  - Avoid container sprawl"
total_containers=$(docker info 2>/dev/null | grep "Containers" | awk '{print $2}')
running_containers=$(docker ps -q | wc -l | awk '{print $1}')
diff="$((total_containers - running_containers))"
if [ "$diff" -gt 25 ]; then
  info "$check_6_2"
  info "     * There are currently a total of $total_containers containers, with only $running_containers of them currently running"
else
  info "$check_6_2"
  info "     * There are currently a total of $total_containers containers, with $running_containers of them currently running"
fi

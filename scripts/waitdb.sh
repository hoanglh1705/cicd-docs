#!/usr/bin/env bash

# Ensure the database container is online and usable
# echo "Waiting for database..."
# until docker exec -i paygate.db mysql -u paygate -padmin123 -D paygate -e "SELECT 1" &> /dev/null
# EnablePostgreSQL: remove the line above, uncomment the following
until docker exec -i paygate.db psql -h localhost -U paygate -d paygate -c "SELECT 1" &> /dev/null
do
  # printf "."
  sleep 1
done

#! /bin/bash

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d mb/development ../latest.dump
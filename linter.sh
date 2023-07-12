#!/bin/sh
#------------------------------------------------------------------------------
# written by:   mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         jul-2023
#
# usage:        Runs terraform fmt -recursive
#------------------------------------------------------------------------------

terraform fmt -recursive
pre-commit run --all-files

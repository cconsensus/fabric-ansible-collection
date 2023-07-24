#
# SPDX-License-Identifier: Apache-2.0
#
set export

default:
    @just --list

fac_version    := env_var_or_default("FAC_VERSION",       "1.2.0")

# Local ansible-galalxy build and install
local:
    ansible-galaxy collection build -f
    ansible-galaxy collection install $(ls -1 | grep ibm-blockchain_platform) -f

# Lint the codebase
lint:
    #!/bin/bash
    set -ex -o pipefail

    flake8 .
    ansible-lint
    for ROLE in roles/*; do ansible-lint ${ROLE}; done
    for PLAYBOOK in tutorial/??-*.yml; do ansible-lint ${PLAYBOOK}; done
    for PLAYBOOK in tutorial/v1.x/??-*.yml; do ansible-lint ${PLAYBOOK}; done
    shellcheck tutorial/*.sh
    yamllint .

#build image
docker:
    # docker build -t fabric-ansible .
    docker build -t cconsensus/fabric-ansible-collection:{{fac_version}} .
    # docker tag cconsensus/fabric-ansible-collection:{{fac_version}} cconsensus/fabric-ansible-collection:latest
    docker push cconsensus/fabric-ansible-collection:{{fac_version}}
    # docker push cconsensus/fabric-ansible-collection:latest
    # docker save cconsensus/fabric-ansible-collection:{{fac_version}} cconsensus/fabric-ansible-collection:latest | gzip -c > image.tar.gz

# Build the documentation
docs:
    #!/bin/bash
    set -ex -o pipefail

    cd docs
    make clean
    make all

toolcheck:
    #!/bin/bash
    set -e -o pipefail

    confirm() {
        if ! command -v $1 &> /dev/null
        then
            echo "$1 could not be found"
            exit
        fi
    }

    confirm "shellcheck"
    confirm "yamllint"


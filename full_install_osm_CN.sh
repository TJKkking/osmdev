#!/bin/bash
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#


function usage(){
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    echo -e "usage: $0 [OPTIONS]"
    echo -e "Install OSM from binaries or source code (by default, from binaries)"
    echo -e "  OPTIONS"
    echo -e "     -h / --help:    print this help"
    echo -e "     -y:             do not prompt for confirmation, assumes yes"
    echo -e "     -r <repo>:      use specified repository name for osm packages"
    echo -e "     -R <release>:   use specified release for osm binaries (deb packages, lxd images, ...)"
    echo -e "     -u <repo base>: use specified repository url for osm packages"
    echo -e "     -k <repo key>:  use specified repository public key url"
    echo -e "     -b <refspec>:   install OSM from source code using a specific branch (master, v2.0, ...) or tag"
    echo -e "                     -b master          (main dev branch)"
    echo -e "                     -b v2.0            (v2.0 branch)"
    echo -e "                     -b tags/v1.1.0     (a specific tag)"
    echo -e "                     ..."
    echo -e "     -a <apt proxy url>: use this apt proxy url when downloading apt packages (air-gapped installation)"
    echo -e "     -s <stack name> or <namespace>  user defined stack name when installed using swarm or namespace when installed using k8s, default is osm"
    echo -e "     -H <VCA host>   use specific juju host controller IP"
    echo -e "     -S <VCA secret> use VCA/juju secret key"
    echo -e "     -P <VCA pubkey> use VCA/juju public key file"
    echo -e "     -A <VCA apiproxy> use VCA/juju API proxy"
    echo -e "     --pla:          install the PLA module for placement support"
    echo -e "     --ng-sa:        install Airflow and Pushgateway to get VNF and NS status (experimental)"
    echo -e "     -m <MODULE>:    install OSM but only rebuild or pull the specified docker images (NG-UI, NBI, LCM, RO, MON, POL, PLA, KAFKA, MONGO, PROMETHEUS, PROMETHEUS-CADVISOR, KEYSTONE-DB, NONE)"
    echo -e "     -o <ADDON>:     ONLY (un)installs one of the addons (k8s_monitor, ng-sa)"
    echo -e "     -O <openrc file path/cloud name>: Install OSM to an OpenStack infrastructure. <openrc file/cloud name> is required. If a <cloud name> is used, the clouds.yaml file should be under ~/.config/openstack/ or /etc/openstack/"
    echo -e "     -N <openstack public network name/ID>: Public network name required to setup OSM to OpenStack"
    echo -e "     -f <path to SSH public key>: Public SSH key to use to deploy OSM to OpenStack"
    echo -e "     -F <path to cloud-init file>: Cloud-Init userdata file to deploy OSM to OpenStack"
    echo -e "     -D <devops path> use local devops installation path"
    echo -e "     -w <work dir>   Location to store runtime installation"
    echo -e "     -t <docker tag> specify osm docker tag (default is latest)"
    echo -e "     -l:             LXD cloud yaml file"
    echo -e "     -L:             LXD credentials yaml file"
    echo -e "     -K:             Specifies the name of the controller to use - The controller must be already bootstrapped"
    echo -e "     -d <docker registry URL> use docker registry URL instead of dockerhub"
    echo -e "     -p <docker proxy URL> set docker proxy URL as part of docker CE configuration"
    echo -e "     -T <docker tag> specify docker tag for the modules specified with option -m"
    echo -e "     --debug:        debug mode"
    echo -e "     --nocachelxdimages:  do not cache local lxd images, do not create cronjob for that cache (will save installation time, might affect instantiation time)"
    echo -e "     --cachelxdimages:  cache local lxd images, create cronjob for that cache (will make installation longer)"
    echo -e "     --nolxd:        do not install and configure LXD, allowing unattended installations (assumes LXD is already installed and confifured)"
    echo -e "     --nodocker:     do not install docker, do not initialize a swarm (assumes docker is already installed and a swarm has been initialized)"
    echo -e "     --nojuju:       do not juju, assumes already installed"
    echo -e "     --nodockerbuild:do not build docker images (use existing locally cached images)"
    echo -e "     --nohostports:  do not expose docker ports to host (useful for creating multiple instances of osm on the same host)"
    echo -e "     --nohostclient: do not install the osmclient"
    echo -e "     --uninstall:    uninstall OSM: remove the containers and delete NAT rules"
    echo -e "     --source:       install OSM from source code using the latest stable tag"
    echo -e "     --develop:      (deprecated, use '-b master') install OSM from source code using the master branch"
    echo -e "     --pullimages:   pull/run osm images from docker.io/opensourcemano"
    echo -e "     --k8s_monitor:  install the OSM kubernetes monitoring with prometheus and grafana"
    echo -e "     --volume:       create a VM volume when installing to OpenStack"
    echo -e "     --showopts:     print chosen options and exit (only for debugging)"
    echo -e "     --charmed:                   Deploy and operate OSM with Charms on k8s"
    echo -e "     [--bundle <bundle path>]:    Specify with which bundle to deploy OSM with charms (--charmed option)"
    echo -e "     [--k8s <kubeconfig path>]:   Specify with which kubernetes to deploy OSM with charms (--charmed option)"
    echo -e "     [--vca <name>]:              Specifies the name of the controller to use - The controller must be already bootstrapped (--charmed option)"
    echo -e "     [--small-profile]:           Do not install and configure LXD which aims to use only K8s Clouds (--charmed option)"
    echo -e "     [--lxd <yaml path>]:         Takes a YAML file as a parameter with the LXD Cloud information (--charmed option)"
    echo -e "     [--lxd-cred <yaml path>]:    Takes a YAML file as a parameter with the LXD Credentials information (--charmed option)"
    echo -e "     [--microstack]:              Installs microstack as a vim. (--charmed option)"
    echo -e "     [--overlay]:                 Add an overlay to override some defaults of the default bundle (--charmed option)"
    echo -e "     [--ha]:                      Installs High Availability bundle. (--charmed option)"
    echo -e "     [--tag]:                     Docker image tag. (--charmed option)"
    echo -e "     [--registry]:                Docker registry with optional credentials as user:pass@hostname:port (--charmed option)"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

# takes a juju/accounts.yaml file and returns the password specific
# for a controller. I wrote this using only bash tools to minimize
# additions of other packages
function parse_juju_password {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    password_file="${HOME}/.local/share/juju/accounts.yaml"
    local controller_name=$1
    local s='[[:space:]]*' w='[a-zA-Z0-9_-]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\):|\1|" \
         -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
         -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $password_file |
    awk -F$fs -v controller=$controller_name '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            if (match(vn,controller) && match($2,"password")) {
                printf("%s",$3);
            }
        }
    }'
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function set_vca_variables() {
    OSM_VCA_CLOUDNAME="lxd-cloud"
    [ -n "$OSM_VCA_HOST" ] && OSM_VCA_CLOUDNAME="localhost"
    if [ -z "$OSM_VCA_HOST" ]; then
        [ -z "$CONTROLLER_NAME" ] && OSM_VCA_HOST=`sg lxd -c "juju show-controller $OSM_STACK_NAME"|grep api-endpoints|awk -F\' '{print $2}'|awk -F\: '{print $1}'`
        [ -n "$CONTROLLER_NAME" ] && OSM_VCA_HOST=`juju show-controller $CONTROLLER_NAME |grep api-endpoints|awk -F\' '{print $2}'|awk -F\: '{print $1}'`
        [ -z "$OSM_VCA_HOST" ] && FATAL "Cannot obtain juju controller IP address"
    fi
    if [ -z "$OSM_VCA_SECRET" ]; then
        [ -z "$CONTROLLER_NAME" ] && OSM_VCA_SECRET=$(parse_juju_password $OSM_STACK_NAME)
        [ -n "$CONTROLLER_NAME" ] && OSM_VCA_SECRET=$(parse_juju_password $CONTROLLER_NAME)
        [ -z "$OSM_VCA_SECRET" ] && FATAL "Cannot obtain juju secret"
    fi
    if [ -z "$OSM_VCA_PUBKEY" ]; then
        OSM_VCA_PUBKEY=$(cat $HOME/.local/share/juju/ssh/juju_id_rsa.pub)
        [ -z "$OSM_VCA_PUBKEY" ] && FATAL "Cannot obtain juju public key"
    fi
    if [ -z "$OSM_VCA_CACERT" ]; then
        [ -z "$CONTROLLER_NAME" ] && OSM_VCA_CACERT=$(juju controllers --format json | jq -r --arg controller $OSM_STACK_NAME '.controllers[$controller]["ca-cert"]' | base64 | tr -d \\n)
        [ -n "$CONTROLLER_NAME" ] && OSM_VCA_CACERT=$(juju controllers --format json | jq -r --arg controller $CONTROLLER_NAME '.controllers[$controller]["ca-cert"]' | base64 | tr -d \\n)
        [ -z "$OSM_VCA_CACERT" ] && FATAL "Cannot obtain juju CA certificate"
    fi
}

function generate_secret() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function check_packages() {
    NEEDED_PACKAGES="$1"
    echo -e "Checking required packages: ${NEEDED_PACKAGES}"
    for PACKAGE in ${NEEDED_PACKAGES} ; do
        dpkg -L ${PACKAGE}
        if [ $? -ne 0 ]; then
            echo -e "Package ${PACKAGE} is not installed."
            echo -e "Updating apt-cache ..."
            sudo apt-get update
            echo -e "Installing ${PACKAGE} ..."
            sudo apt-get install -y ${PACKAGE} || FATAL "failed to install ${PACKAGE}"
        fi
    done
    echo -e "Required packages are present: ${NEEDED_PACKAGES}"
}

function ask_user(){
    # ask to the user and parse a response among 'y', 'yes', 'n' or 'no'. Case insensitive
    # Params: $1 text to ask;   $2 Action by default, can be 'y' for yes, 'n' for no, other or empty for not allowed
    # Return: true(0) if user type 'yes'; false (1) if user type 'no'
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    read -e -p "$1" USER_CONFIRMATION
    while true ; do
        [ -z "$USER_CONFIRMATION" ] && [ "$2" == 'y' ] && return 0
        [ -z "$USER_CONFIRMATION" ] && [ "$2" == 'n' ] && return 1
        [ "${USER_CONFIRMATION,,}" == "yes" ] || [ "${USER_CONFIRMATION,,}" == "y" ] && return 0
        [ "${USER_CONFIRMATION,,}" == "no" ]  || [ "${USER_CONFIRMATION,,}" == "n" ] && return 1
        read -e -p "Please type 'yes' or 'no': " USER_CONFIRMATION
    done
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function install_osmclient(){
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    CLIENT_RELEASE=${RELEASE#"-R "}
    CLIENT_REPOSITORY_KEY="OSM%20ETSI%20Release%20Key.gpg"
    CLIENT_REPOSITORY=${REPOSITORY#"-r "}
    CLIENT_REPOSITORY_BASE=${REPOSITORY_BASE#"-u "}
    key_location=$CLIENT_REPOSITORY_BASE/$CLIENT_RELEASE/$CLIENT_REPOSITORY_KEY
    curl $key_location | sudo APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] $CLIENT_REPOSITORY_BASE/$CLIENT_RELEASE $CLIENT_REPOSITORY osmclient IM"
    sudo apt-get update
    sudo apt-get install -y python3-pip
    sudo -H LC_ALL=C python3 -m pip install -U pip
    sudo -H LC_ALL=C python3 -m pip install -U python-magic pyangbind verboselogs
    sudo apt-get install -y python3-osm-im python3-osmclient
    if [ -f /usr/lib/python3/dist-packages/osm_im/requirements.txt ]; then
        python3 -m pip install -r /usr/lib/python3/dist-packages/osm_im/requirements.txt
    fi
    if [ -f /usr/lib/python3/dist-packages/osmclient/requirements.txt ]; then
        sudo apt-get install -y libcurl4-openssl-dev libssl-dev libmagic1
        python3 -m pip install -r /usr/lib/python3/dist-packages/osmclient/requirements.txt
    fi
    [ -z "$INSTALL_LIGHTWEIGHT" ] && export OSM_HOSTNAME=`lxc list | awk '($2=="SO-ub"){print $6}'`
    [ -z "$INSTALL_LIGHTWEIGHT" ] && export OSM_RO_HOSTNAME=`lxc list | awk '($2=="RO"){print $6}'`
    echo -e "\nOSM client installed"
    if [ -z "$INSTALL_LIGHTWEIGHT" ]; then
        echo -e "You might be interested in adding the following OSM client env variables to your .bashrc file:"
        echo "     export OSM_HOSTNAME=${OSM_HOSTNAME}"
        echo "     export OSM_RO_HOSTNAME=${OSM_RO_HOSTNAME}"
    else
        echo -e "OSM client assumes that OSM host is running in localhost (127.0.0.1)."
        echo -e "In case you want to interact with a different OSM host, you will have to configure this env variable in your .bashrc file:"
        echo "     export OSM_HOSTNAME=<OSM_host>"
    fi
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
    return 0
}

function docker_login() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    echo "Docker login"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG "Docker registry user: ${DOCKER_REGISTRY_USER}"
    sg docker -c "docker login -u ${DOCKER_REGISTRY_USER} -p ${DOCKER_REGISTRY_PASSWORD} --password-stdin"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function generate_docker_images() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    echo "Pulling and generating docker images"
    [ -n "${DOCKER_REGISTRY_URL}" ] && docker_login

    echo "Pulling docker images"

    if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q KAFKA ; then
        sg docker -c "docker pull wurstmeister/zookeeper" || FATAL "cannot get zookeeper docker image"
        sg docker -c "docker pull wurstmeister/kafka:${KAFKA_TAG}" || FATAL "cannot get kafka docker image"
    fi

    if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q PROMETHEUS ; then
        sg docker -c "docker pull prom/prometheus:${PROMETHEUS_TAG}" || FATAL "cannot get prometheus docker image"
    fi

    if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q PROMETHEUS-CADVISOR ; then
        sg docker -c "docker pull google/cadvisor:${PROMETHEUS_CADVISOR_TAG}" || FATAL "cannot get prometheus cadvisor docker image"
    fi

    if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q GRAFANA ; then
        sg docker -c "docker pull grafana/grafana:${GRAFANA_TAG}" || FATAL "cannot get grafana docker image"
        sg docker -c "docker pull kiwigrid/k8s-sidecar:${KIWIGRID_K8S_SIDECAR_TAG}" || FATAL "cannot get kiwigrid k8s-sidecar docker image"
    fi

    if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q NBI || echo $TO_REBUILD | grep -q KEYSTONE-DB ; then
        sg docker -c "docker pull mariadb:${KEYSTONEDB_TAG}" || FATAL "cannot get keystone-db docker image"
    fi

    if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q RO ; then
        sg docker -c "docker pull mysql:5" || FATAL "cannot get mysql docker image"
    fi

    if [ -n "$PULL_IMAGES" ]; then
        echo "Pulling OSM docker images"
	# for module in MON POL NBI KEYSTONE RO LCM NG-UI PLA osmclient; do
        for module in MON POL NBI KEYSTONE RO LCM PLA osmclient; do
            module_lower=${module,,}
            if [ $module == "PLA" -a ! -n "$INSTALL_PLA" ]; then
                continue
            fi
            module_tag="${OSM_DOCKER_TAG}"
            if [ -n "${MODULE_DOCKER_TAG}" ] && echo $TO_REBUILD | grep -q $module ; then
                module_tag="${MODULE_DOCKER_TAG}"
            fi
            echo "Pulling ${DOCKER_REGISTRY_URL}${DOCKER_USER}/${module_lower}:${module_tag} docker image"
            sg docker -c "docker pull ${DOCKER_REGISTRY_URL}${DOCKER_USER}/${module_lower}:${module_tag}" || FATAL "cannot pull $module docker image"
        done

        #### TJK-build NG-UI from modified code
        module=NG-UI
        module_lower=${module,,}
        _build_from=$COMMIT_ID
        [ -z "$_build_from" ] && _build_from="latest"
        echo "OSM Docker images generated from $_build_from"
        LWTEMPDIR="$(mktemp -d -q --tmpdir "installosmlight.XXXXXX")"
        trap 'rm -rf "${LWTEMPDIR}"' EXIT
        # just build NG-UI
        if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q ${module} ; then
            module_lower=${module,,}
            if [ $module == "PLA" -a ! -n "$INSTALL_PLA" ]; then
                continue
            fi
            git -C ${LWTEMPDIR} clone https://github.com/TJKkking/NG-UI.git
            git -C ${LWTEMPDIR}/${module} checkout ${COMMIT_ID}
            sg docker -c "docker build ${LWTEMPDIR}/${module} -f ${LWTEMPDIR}/${module}/docker/Dockerfile -t ${DOCKER_USER}/${module_lower}:tjkcn --no-cache" || FATAL "cannot build ${module} docker image"
        fi  
       	echo "NG-UI build success!!!"	
        #### TJK-build NG-UI from modified code

    else
        _build_from=$COMMIT_ID
        [ -z "$_build_from" ] && _build_from="latest"
        echo "OSM Docker images generated from $_build_from"
        LWTEMPDIR="$(mktemp -d -q --tmpdir "installosmlight.XXXXXX")"
        trap 'rm -rf "${LWTEMPDIR}"' EXIT
        for module in MON POL NBI KEYSTONE RO LCM NG-UI PLA; do
            if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q ${module} ; then
                module_lower=${module,,}
                if [ $module == "PLA" -a ! -n "$INSTALL_PLA" ]; then
                    continue
                fi
                git -C ${LWTEMPDIR} clone https://osm.etsi.org/gerrit/osm/$module
                git -C ${LWTEMPDIR}/${module} checkout ${COMMIT_ID}
                sg docker -c "docker build ${LWTEMPDIR}/${module} -f ${LWTEMPDIR}/${module}/docker/Dockerfile -t ${DOCKER_USER}/${module_lower} --no-cache" || FATAL "cannot build ${module} docker image"
            fi
        done
        if [ -z "$TO_REBUILD" ] || echo $TO_REBUILD | grep -q osmclient; then
            BUILD_ARGS+=(--build-arg REPOSITORY="$REPOSITORY")
            BUILD_ARGS+=(--build-arg RELEASE="$RELEASE")
            BUILD_ARGS+=(--build-arg REPOSITORY_KEY="$REPOSITORY_KEY")
            BUILD_ARGS+=(--build-arg REPOSITORY_BASE="$REPOSITORY_BASE")
            sg docker -c "docker build -t ${DOCKER_USER}/osmclient ${BUILD_ARGS[@]} -f $OSM_DEVOPS/docker/osmclient ."
        fi
        echo "Finished generation of docker images"
    fi


    # TJK added
    # 提示用户确认
    read -p "您确定要继续执行吗？(y/n): " confirm
    
    # 将用户输入转换为小写
    confirm=${confirm,,}
 
    # 检查用户输入是否为 "y" 或 "yes"，如果是则继续执行，否则退出脚本
    if [[ $confirm == "y" || $confirm == "yes" ]]; then
        echo "继续执行..."
    else
        echo "已取消执行."
        exit 0
    fi
    # TJK added

    echo "Finished pulling and generating docker images"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function cmp_overwrite() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    file1="$1"
    file2="$2"
    if ! $(cmp "${file1}" "${file2}" >/dev/null 2>&1); then
        if [ -f "${file2}" ]; then
            ask_user "The file ${file2} already exists. Overwrite (y/N)? " n && cp -b ${file1} ${file2}
        else
            cp -b ${file1} ${file2}
        fi
    fi
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function generate_k8s_manifest_files() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    #Kubernetes resources
    sudo cp -bR ${OSM_DEVOPS}/installers/docker/osm_pods $OSM_DOCKER_WORK_DIR
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function generate_docker_env_files() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    echo "Doing a backup of existing env files"
    sudo cp $OSM_DOCKER_WORK_DIR/keystone-db.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/keystone.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/lcm.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/mon.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/nbi.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/pol.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/ro-db.env{,~}
    sudo cp $OSM_DOCKER_WORK_DIR/ro.env{,~}
    if [ -n "${INSTALL_NGSA}" ]; then
        sudo cp $OSM_DOCKER_WORK_DIR/ngsa.env{,~}
    fi

    echo "Generating docker env files"
    # LCM
    if [ ! -f $OSM_DOCKER_WORK_DIR/lcm.env ]; then
        echo "OSMLCM_DATABASE_COMMONKEY=${OSM_DATABASE_COMMONKEY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_HOST" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "OSMLCM_VCA_HOST=${OSM_VCA_HOST}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    else
        sudo sed -i "s|OSMLCM_VCA_HOST.*|OSMLCM_VCA_HOST=$OSM_VCA_HOST|g" $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_SECRET" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "OSMLCM_VCA_SECRET=${OSM_VCA_SECRET}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    else
        sudo sed -i "s|OSMLCM_VCA_SECRET.*|OSMLCM_VCA_SECRET=$OSM_VCA_SECRET|g" $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_PUBKEY" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "OSMLCM_VCA_PUBKEY=${OSM_VCA_PUBKEY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    else
        sudo sed -i "s|OSMLCM_VCA_PUBKEY.*|OSMLCM_VCA_PUBKEY=${OSM_VCA_PUBKEY}|g" $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_CACERT" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "OSMLCM_VCA_CACERT=${OSM_VCA_CACERT}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    else
        sudo sed -i "s|OSMLCM_VCA_CACERT.*|OSMLCM_VCA_CACERT=${OSM_VCA_CACERT}|g" $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if [ -n "$OSM_VCA_APIPROXY" ]; then
        if ! grep -Fq "OSMLCM_VCA_APIPROXY" $OSM_DOCKER_WORK_DIR/lcm.env; then
            echo "OSMLCM_VCA_APIPROXY=${OSM_VCA_APIPROXY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
        else
            sudo sed -i "s|OSMLCM_VCA_APIPROXY.*|OSMLCM_VCA_APIPROXY=${OSM_VCA_APIPROXY}|g" $OSM_DOCKER_WORK_DIR/lcm.env
        fi
    fi

    if ! grep -Fq "OSMLCM_VCA_ENABLEOSUPGRADE" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "# OSMLCM_VCA_ENABLEOSUPGRADE=false" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_APTMIRROR" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "# OSMLCM_VCA_APTMIRROR=http://archive.ubuntu.com/ubuntu/" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_CLOUD" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "OSMLCM_VCA_CLOUD=${OSM_VCA_CLOUDNAME}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    else
        sudo sed -i "s|OSMLCM_VCA_CLOUD.*|OSMLCM_VCA_CLOUD=${OSM_VCA_CLOUDNAME}|g" $OSM_DOCKER_WORK_DIR/lcm.env
    fi

    if ! grep -Fq "OSMLCM_VCA_K8S_CLOUD" $OSM_DOCKER_WORK_DIR/lcm.env; then
        echo "OSMLCM_VCA_K8S_CLOUD=${OSM_VCA_K8S_CLOUDNAME}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
    else
        sudo sed -i "s|OSMLCM_VCA_K8S_CLOUD.*|OSMLCM_VCA_K8S_CLOUD=${OSM_VCA_K8S_CLOUDNAME}|g" $OSM_DOCKER_WORK_DIR/lcm.env
    fi
    if [ -n "${OSM_BEHIND_PROXY}" ]; then
        if ! grep -Fq "HTTP_PROXY" $OSM_DOCKER_WORK_DIR/lcm.env; then
            echo "HTTP_PROXY=${HTTP_PROXY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
        else
            sudo sed -i "s|HTTP_PROXY.*|HTTP_PROXY=${HTTP_PROXY}|g" $OSM_DOCKER_WORK_DIR/lcm.env
        fi
        if ! grep -Fq "HTTPS_PROXY" $OSM_DOCKER_WORK_DIR/lcm.env; then
            echo "HTTPS_PROXY=${HTTPS_PROXY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
        else
            sudo sed -i "s|HTTPS_PROXY.*|HTTPS_PROXY=${HTTPS_PROXY}|g" $OSM_DOCKER_WORK_DIR/lcm.env
        fi
        if ! grep -Fq "NO_PROXY" $OSM_DOCKER_WORK_DIR/lcm.env; then
            echo "NO_PROXY=${NO_PROXY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/lcm.env
        else
            sudo sed -i "s|NO_PROXY.*|NO_PROXY=${NO_PROXY}|g" $OSM_DOCKER_WORK_DIR/lcm.env
        fi
    fi

    # RO
    MYSQL_ROOT_PASSWORD=$(generate_secret)
    if [ ! -f $OSM_DOCKER_WORK_DIR/ro-db.env ]; then
        echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" |sudo tee $OSM_DOCKER_WORK_DIR/ro-db.env
    fi
    if [ ! -f $OSM_DOCKER_WORK_DIR/ro.env ]; then
        echo "RO_DB_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" |sudo tee $OSM_DOCKER_WORK_DIR/ro.env
    fi
    if ! grep -Fq "OSMRO_DATABASE_COMMONKEY" $OSM_DOCKER_WORK_DIR/ro.env; then
        echo "OSMRO_DATABASE_COMMONKEY=${OSM_DATABASE_COMMONKEY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/ro.env
    fi

    # Keystone
    KEYSTONE_DB_PASSWORD=$(generate_secret)
    SERVICE_PASSWORD=$(generate_secret)
    if [ ! -f $OSM_DOCKER_WORK_DIR/keystone-db.env ]; then
        echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" |sudo tee $OSM_DOCKER_WORK_DIR/keystone-db.env
    fi
    if [ ! -f $OSM_DOCKER_WORK_DIR/keystone.env ]; then
        echo "ROOT_DB_PASSWORD=${MYSQL_ROOT_PASSWORD}" |sudo tee $OSM_DOCKER_WORK_DIR/keystone.env
        echo "KEYSTONE_DB_PASSWORD=${KEYSTONE_DB_PASSWORD}" |sudo tee -a $OSM_DOCKER_WORK_DIR/keystone.env
        echo "SERVICE_PASSWORD=${SERVICE_PASSWORD}" |sudo tee -a $OSM_DOCKER_WORK_DIR/keystone.env
    fi

    # NBI
    if [ ! -f $OSM_DOCKER_WORK_DIR/nbi.env ]; then
        echo "OSMNBI_AUTHENTICATION_SERVICE_PASSWORD=${SERVICE_PASSWORD}" |sudo tee $OSM_DOCKER_WORK_DIR/nbi.env
        echo "OSMNBI_DATABASE_COMMONKEY=${OSM_DATABASE_COMMONKEY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/nbi.env
    fi

    # MON
    if [ ! -f $OSM_DOCKER_WORK_DIR/mon.env ]; then
        echo "OSMMON_KEYSTONE_SERVICE_PASSWORD=${SERVICE_PASSWORD}" | sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
        echo "OSMMON_DATABASE_COMMONKEY=${OSM_DATABASE_COMMONKEY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
        echo "OSMMON_SQL_DATABASE_URI=mysql://root:${MYSQL_ROOT_PASSWORD}@mysql:3306/mon" | sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
    fi

    if ! grep -Fq "OS_NOTIFIER_URI" $OSM_DOCKER_WORK_DIR/mon.env; then
        echo "OS_NOTIFIER_URI=http://${OSM_DEFAULT_IP}:8662" |sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
    else
        sudo sed -i "s|OS_NOTIFIER_URI.*|OS_NOTIFIER_URI=http://$OSM_DEFAULT_IP:8662|g" $OSM_DOCKER_WORK_DIR/mon.env
    fi

    if ! grep -Fq "OSMMON_VCA_HOST" $OSM_DOCKER_WORK_DIR/mon.env; then
        echo "OSMMON_VCA_HOST=${OSM_VCA_HOST}" | sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
    else
        sudo sed -i "s|OSMMON_VCA_HOST.*|OSMMON_VCA_HOST=$OSM_VCA_HOST|g" $OSM_DOCKER_WORK_DIR/mon.env
    fi

    if ! grep -Fq "OSMMON_VCA_SECRET" $OSM_DOCKER_WORK_DIR/mon.env; then
        echo "OSMMON_VCA_SECRET=${OSM_VCA_SECRET}" | sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
    else
        sudo sed -i "s|OSMMON_VCA_SECRET.*|OSMMON_VCA_SECRET=$OSM_VCA_SECRET|g" $OSM_DOCKER_WORK_DIR/mon.env
    fi

    if ! grep -Fq "OSMMON_VCA_CACERT" $OSM_DOCKER_WORK_DIR/mon.env; then
        echo "OSMMON_VCA_CACERT=${OSM_VCA_CACERT}" | sudo tee -a $OSM_DOCKER_WORK_DIR/mon.env
    else
        sudo sed -i "s|OSMMON_VCA_CACERT.*|OSMMON_VCA_CACERT=${OSM_VCA_CACERT}|g" $OSM_DOCKER_WORK_DIR/mon.env
    fi

    # POL
    if [ ! -f $OSM_DOCKER_WORK_DIR/pol.env ]; then
        echo "OSMPOL_SQL_DATABASE_URI=mysql://root:${MYSQL_ROOT_PASSWORD}@mysql:3306/pol" | sudo tee -a $OSM_DOCKER_WORK_DIR/pol.env
    fi

    # NG-SA
    if [ -n "${INSTALL_NGSA}" ] && [ ! -f $OSM_DOCKER_WORK_DIR/ngsa.env ]; then
        echo "OSMMON_DATABASE_COMMONKEY=${OSM_DATABASE_COMMONKEY}" | sudo tee -a $OSM_DOCKER_WORK_DIR/ngsa.env
    fi

    echo "Finished generation of docker env files"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

#creates secrets from env files which will be used by containers
function kube_secrets(){
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    kubectl create ns $OSM_STACK_NAME
    kubectl create secret generic lcm-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/lcm.env
    kubectl create secret generic mon-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/mon.env
    kubectl create secret generic nbi-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/nbi.env
    kubectl create secret generic ro-db-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/ro-db.env
    kubectl create secret generic ro-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/ro.env
    kubectl create secret generic keystone-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/keystone.env
    kubectl create secret generic pol-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/pol.env
    if [ -n "${INSTALL_NGSA}" ]; then
        kubectl create secret generic ngsa-secret -n $OSM_STACK_NAME --from-env-file=$OSM_DOCKER_WORK_DIR/ngsa.env
    fi
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

#deploys osm pods and services
function deploy_osm_services() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    kubectl apply -n $OSM_STACK_NAME -f $OSM_K8S_WORK_DIR
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

#deploy charmed services
function deploy_charmed_services() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    juju add-model $OSM_STACK_NAME $OSM_VCA_K8S_CLOUDNAME
    juju deploy ch:mongodb-k8s -m $OSM_STACK_NAME
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function deploy_osm_pla_service() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    # corresponding to deploy_osm_services
    kubectl apply -n $OSM_STACK_NAME -f $OSM_DOCKER_WORK_DIR/osm_pla
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function install_osm_ngsa_service() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    $OSM_DEVOPS/installers/install_ngsa.sh -d ${OSM_HELM_WORK_DIR} -D ${OSM_DEVOPS} -t ${OSM_DOCKER_TAG} ${DEBUG_INSTALL} || \
    FATAL_TRACK install_osm_ngsa_service "install_ngsa.sh failed"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function parse_yaml() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    TAG=$1
    shift
    services=$@
    for module in $services; do
        if [ "$module" == "pla" ]; then
            if [ -n "$INSTALL_PLA" ]; then
                echo "Updating K8s manifest file from opensourcemano\/pla:.* to ${DOCKER_REGISTRY_URL}${DOCKER_USER}\/pla:${TAG}"
                sudo sed -i "s#opensourcemano/pla:.*#${DOCKER_REGISTRY_URL}${DOCKER_USER}/pla:${TAG}#g" ${OSM_DOCKER_WORK_DIR}/osm_pla/pla.yaml
            fi
        else
            image=${module}
            if [ "$module" == "ng-prometheus" ]; then
                image="prometheus"
            fi
            echo "Updating K8s manifest file from opensourcemano\/${image}:.* to ${DOCKER_REGISTRY_URL}${DOCKER_USER}\/${image}:${TAG}"
            sudo sed -i "s#opensourcemano/${image}:.*#${DOCKER_REGISTRY_URL}${DOCKER_USER}/${image}:${TAG}#g" ${OSM_K8S_WORK_DIR}/${module}.yaml
        fi
    done
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function update_manifest_files() {
    osm_services="nbi lcm ro pol mon ng-ui keystone pla prometheus ng-prometheus"
    list_of_services=""
    for module in $osm_services; do
        module_upper="${module^^}"
        if ! echo $TO_REBUILD | grep -q $module_upper ; then
            list_of_services="$list_of_services $module"
        fi
    done
    if [ ! "$OSM_DOCKER_TAG" == "13" ]; then
        parse_yaml $OSM_DOCKER_TAG $list_of_services
    fi
    if [ -n "$MODULE_DOCKER_TAG" ]; then
        parse_yaml $MODULE_DOCKER_TAG $list_of_services_to_rebuild
    fi
    # The manifest for prometheus is prometheus.yaml or ng-prometheus.yaml, depending on the installation option
    if [ -n "$INSTALL_NGSA" ]; then
        sudo rm -f ${OSM_K8S_WORK_DIR}/prometheus.yaml
    else
        sudo rm -f ${OSM_K8S_WORK_DIR}/ng-prometheus.yaml
    fi
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function namespace_vol() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    # List of services with a volume mounted in path /var/lib/osm
    osm_services="mysql"
    for osm in $osm_services; do
        if [ -f "$OSM_K8S_WORK_DIR/$osm.yaml" ] ; then
            sudo sed -i "s#path: /var/lib/osm#path: $OSM_NAMESPACE_VOL#g" $OSM_K8S_WORK_DIR/$osm.yaml
        fi
    done
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function add_local_k8scluster() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    /usr/bin/osm --all-projects vim-create \
      --name _system-osm-vim \
      --account_type dummy \
      --auth_url http://dummy \
      --user osm --password osm --tenant osm \
      --description "dummy" \
      --config '{management_network_name: mgmt}'
    /usr/bin/osm --all-projects k8scluster-add \
      --creds ${HOME}/.kube/config \
      --vim _system-osm-vim \
      --k8s-nets '{"net1": null}' \
      --version '1.15' \
      --description "OSM Internal Cluster" \
      _system-osm-k8s
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function configure_apt_proxy() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    OSM_APT_PROXY=$1
    OSM_APT_PROXY_FILE="/etc/apt/apt.conf.d/osm-apt"
    echo "Configuring apt proxy in file ${OSM_APT_PROXY_FILE}"
    if [ ! -f ${OSM_APT_PROXY_FILE} ]; then
        sudo bash -c "cat <<EOF > ${OSM_APT_PROXY}
Acquire::http { Proxy \"${OSM_APT_PROXY}\"; }
EOF"
    else
        sudo sed -i "s|Proxy.*|Proxy \"${OSM_APT_PROXY}\"; }|" ${OSM_APT_PROXY_FILE}
    fi
    sudo apt-get update || FATAL "Configured apt proxy, but couldn't run 'apt-get update'. Check ${OSM_APT_PROXY_FILE}"
    track prereq apt_proxy_configured_ok
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function ask_proceed() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function

    [ -z "$ASSUME_YES" ] && ! ask_user "The installation will do the following
    1. Install and configure LXD
    2. Install juju
    3. Install docker CE
    4. Disable swap space
    5. Install and initialize Kubernetes
    as pre-requirements.
    Do you want to proceed (Y/n)? " y && echo "Cancelled!" && exit 1

    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function check_osm_behind_proxy() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function

    export OSM_BEHIND_PROXY=""
    export OSM_PROXY_ENV_VARIABLES=""
    [ -n "${http_proxy}" ] && OSM_BEHIND_PROXY="y" && echo "http_proxy=${http_proxy}" && OSM_PROXY_ENV_VARIABLES="${OSM_PROXY_ENV_VARIABLES} http_proxy"
    [ -n "${https_proxy}" ] && OSM_BEHIND_PROXY="y" && echo "https_proxy=${https_proxy}" && OSM_PROXY_ENV_VARIABLES="${OSM_PROXY_ENV_VARIABLES} https_proxy"
    [ -n "${HTTP_PROXY}" ] && OSM_BEHIND_PROXY="y" && echo "HTTP_PROXY=${HTTP_PROXY}" && OSM_PROXY_ENV_VARIABLES="${OSM_PROXY_ENV_VARIABLES} HTTP_PROXY"
    [ -n "${HTTPS_PROXY}" ] && OSM_BEHIND_PROXY="y" && echo "https_proxy=${HTTPS_PROXY}" && OSM_PROXY_ENV_VARIABLES="${OSM_PROXY_ENV_VARIABLES} HTTPS_PROXY"
    [ -n "${no_proxy}" ] && echo "no_proxy=${no_proxy}" && OSM_PROXY_ENV_VARIABLES="${OSM_PROXY_ENV_VARIABLES} no_proxy"
    [ -n "${NO_PROXY}" ] && echo "NO_PROXY=${NO_PROXY}" && OSM_PROXY_ENV_VARIABLES="${OSM_PROXY_ENV_VARIABLES} NO_PROXY"

    echo "OSM_BEHIND_PROXY=${OSM_BEHIND_PROXY}"
    echo "OSM_PROXY_ENV_VARIABLES=${OSM_PROXY_ENV_VARIABLES}"

    if [ -n "${OSM_BEHIND_PROXY}" ]; then
        [ -z "$ASSUME_YES" ] && ! ask_user "
The following env variables have been found for the current user:
${OSM_PROXY_ENV_VARIABLES}.

This suggests that this machine is behind a proxy and a special configuration is required.
The installer will install Docker CE, LXD and Juju to work behind a proxy using those
env variables.

Take into account that the installer uses apt, curl, wget, docker, lxd, juju and snap.
Depending on the program, the env variables to work behind a proxy might be different
(e.g. http_proxy vs HTTP_PROXY).

For that reason, it is strongly recommended that at least http_proxy, https_proxy, HTTP_PROXY
and HTTPS_PROXY are defined.

Finally, some of the programs (apt, snap) those programs are run as sudoer, requiring that
those env variables are also set for root user. If you are not sure whether those variables
are configured for the root user, you can stop the installation now.

Do you want to proceed with the installation (Y/n)? " y && echo "Cancelled!" && exit 1
    else
        echo "This machine is not behind a proxy"
    fi

    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function find_devops_folder() {
    if [ -z "$OSM_DEVOPS" ]; then
        if [ -n "$TEST_INSTALLER" ]; then
            echo -e "\nUsing local devops repo for OSM installation"
            OSM_DEVOPS="$(dirname $(realpath $(dirname $0)))"
        else
            echo -e "\nCreating temporary dir for OSM installation"
            OSM_DEVOPS="$(mktemp -d -q --tmpdir "installosm.XXXXXX")"
            trap 'rm -rf "$OSM_DEVOPS"' EXIT
            git clone https://osm.etsi.org/gerrit/osm/devops.git $OSM_DEVOPS
        fi
    fi
}

function install_osm() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function

    trap ctrl_c INT

    # TODO: move this under start
    [ -n "$DOCKER_REGISTRY_URL" ] && parse_docker_registry_url

    check_osm_behind_proxy
    track checks proxy_ok

    check_packages "git wget curl tar snapd"

    sudo snap install jq || FATAL "Could not install jq (snap package). Make sure that snap works"

    find_devops_folder

    # TODO: the use of stacks come from docker-compose. We should probably remove
    [ "${OSM_STACK_NAME}" == "osm" ] || OSM_DOCKER_WORK_DIR="$OSM_WORK_DIR/stack/$OSM_STACK_NAME"

    track start release $RELEASE none none docker_tag $OSM_DOCKER_TAG none none installation_type $OSM_INSTALLATION_TYPE none none

    track checks checkingroot_ok
    [ "$USER" == "root" ] && FATAL "You are running the installer as root. The installer is prepared to be executed as a normal user with sudo privileges."
    track checks noroot_ok

    ask_proceed
    track checks proceed_ok

    echo "Installing OSM"

    echo "Determining IP address of the interface with the default route"
    [ -z "$OSM_DEFAULT_IF" ] && OSM_DEFAULT_IF=$(ip route list|awk '$1=="default" {print $5; exit}')
    [ -z "$OSM_DEFAULT_IF" ] && OSM_DEFAULT_IF=$(route -n |awk '$1~/^0.0.0.0/ {print $8; exit}')
    [ -z "$OSM_DEFAULT_IF" ] && FATAL "Not possible to determine the interface with the default route 0.0.0.0"
    OSM_DEFAULT_IP=`ip -o -4 a s ${OSM_DEFAULT_IF} |awk '{split($4,a,"/"); print a[1]; exit}'`
    [ -z "$OSM_DEFAULT_IP" ] && FATAL "Not possible to determine the IP address of the interface with the default route"

    # configure apt proxy
    [ -n "$APT_PROXY_URL" ] && configure_apt_proxy $APT_PROXY_URL

    # if no host is passed in, we need to install lxd/juju, unless explicilty asked not to
    if [ -z "$OSM_VCA_HOST" ] && [ -z "$INSTALL_NOLXD" ] && [ -z "$LXD_CLOUD_FILE" ]; then
        LXD_INSTALL_OPTS="-D ${OSM_DEVOPS} -i ${OSM_DEFAULT_IF} ${DEBUG_INSTALL}"
        [ -n "${OSM_BEHIND_PROXY}" ] && LXD_INSTALL_OPTS="${LXD_INSTALL_OPTS} -P"
        $OSM_DEVOPS/installers/install_lxd.sh ${LXD_INSTALL_OPTS} || FATAL_TRACK lxd "install_lxd.sh failed"
    fi

    track prereq prereqok_ok

    if [ ! -n "$INSTALL_NODOCKER" ]; then
        DOCKER_CE_OPTS="-D ${OSM_DEVOPS} ${DEBUG_INSTALL}"
        [ -n "${DOCKER_PROXY_URL}" ] && DOCKER_CE_OPTS="${DOCKER_CE_OPTS} -p ${DOCKER_PROXY_URL}"
        [ -n "${OSM_BEHIND_PROXY}" ] && DOCKER_CE_OPTS="${DOCKER_CE_OPTS} -P"
        $OSM_DEVOPS/installers/install_docker_ce.sh ${DOCKER_CE_OPTS} || FATAL_TRACK docker_ce "install_docker_ce.sh failed"
    fi

    track docker_ce docker_ce_ok

    echo "Creating folders for installation"
    [ ! -d "$OSM_DOCKER_WORK_DIR" ] && sudo mkdir -p $OSM_DOCKER_WORK_DIR
    [ ! -d "$OSM_DOCKER_WORK_DIR/osm_pla" -a -n "$INSTALL_PLA" ] && sudo mkdir -p $OSM_DOCKER_WORK_DIR/osm_pla
    sudo cp -b $OSM_DEVOPS/installers/docker/cluster-config.yaml $OSM_DOCKER_WORK_DIR/cluster-config.yaml

    $OSM_DEVOPS/installers/install_kubeadm_cluster.sh -i ${OSM_DEFAULT_IP} -d ${OSM_DOCKER_WORK_DIR} -D ${OSM_DEVOPS} ${DEBUG_INSTALL} || \
    FATAL_TRACK k8scluster "install_kubeadm_cluster.sh failed"
    track k8scluster k8scluster_ok

    JUJU_OPTS="-D ${OSM_DEVOPS} -s ${OSM_STACK_NAME} -i ${OSM_DEFAULT_IP} ${DEBUG_INSTALL} ${INSTALL_NOJUJU} ${INSTALL_CACHELXDIMAGES}"
    [ -n "${OSM_VCA_HOST}" ] && JUJU_OPTS="$JUJU_OPTS -H ${OSM_VCA_HOST}"
    [ -n "${LXD_CLOUD_FILE}" ] && JUJU_OPTS="$JUJU_OPTS -l ${LXD_CLOUD_FILE}"
    [ -n "${LXD_CRED_FILE}" ] && JUJU_OPTS="$JUJU_OPTS -L ${LXD_CRED_FILE}"
    [ -n "${CONTROLLER_NAME}" ] && JUJU_OPTS="$JUJU_OPTS -K ${CONTROLLER_NAME}"
    [ -n "${OSM_BEHIND_PROXY}" ] && JUJU_OPTS="${JUJU_OPTS} -P"
    $OSM_DEVOPS/installers/install_juju.sh ${JUJU_OPTS} || FATAL_TRACK juju "install_juju.sh failed"
    set_vca_variables
    track juju juju_ok

    if [ -z "$OSM_DATABASE_COMMONKEY" ]; then
        OSM_DATABASE_COMMONKEY=$(generate_secret)
        [ -z "OSM_DATABASE_COMMONKEY" ] && FATAL "Cannot generate common db secret"
    fi

    # Deploy OSM services
    [ -z "$DOCKER_NOBUILD" ] && generate_docker_images
    track docker_images docker_images_ok

    generate_k8s_manifest_files
    track osm_files manifest_files_ok
    generate_docker_env_files
    track osm_files env_files_ok

    deploy_charmed_services
    track deploy_osm deploy_charmed_services_ok
    kube_secrets
    track deploy_osm kube_secrets_ok
    update_manifest_files
    track deploy_osm update_manifest_files_ok
    namespace_vol
    track deploy_osm namespace_vol_ok
    deploy_osm_services
    track deploy_osm deploy_osm_services_k8s_ok
    if [ -n "$INSTALL_PLA" ]; then
        # optional PLA install
        deploy_osm_pla_service
        track deploy_osm deploy_osm_pla_ok
    fi
    if [ -n "$INSTALL_K8S_MONITOR" ]; then
        # install OSM MONITORING
        install_k8s_monitoring
        track deploy_osm install_k8s_monitoring_ok
    fi
    if [ -n "$INSTALL_NGSA" ]; then
        # optional PLA install
        install_osm_ngsa_service
        track deploy_osm install_osm_ngsa_ok
    fi

    [ -z "$INSTALL_NOHOSTCLIENT" ] && install_osmclient
    track osmclient osmclient_ok

    echo -e "Checking OSM health state..."
    $OSM_DEVOPS/installers/osm_health.sh -s ${OSM_STACK_NAME} -k || \
    (echo -e "OSM is not healthy, but will probably converge to a healthy state soon." && \
    echo -e "Check OSM status with: kubectl -n ${OSM_STACK_NAME} get all" && \
    track healthchecks osm_unhealthy didnotconverge)
    track healthchecks after_healthcheck_ok

    add_local_k8scluster
    track final_ops add_local_k8scluster_ok

    arrange_docker_default_network_policy

    wget -q -O- https://osm-download.etsi.org/ftp/osm-13.0-thirteen/README2.txt &> /dev/null
    track end
    sudo find /etc/osm
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
    return 0
}

function install_to_openstack() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function

    if [ -z "$2" ]; then
        FATAL "OpenStack installer requires a valid external network name"
    fi

    # Install Pip for Python3
    sudo apt install -y python3-pip python3-venv
    sudo -H LC_ALL=C python3 -m pip install -U pip

    # Create a venv to avoid conflicts with the host installation
    python3 -m venv $OPENSTACK_PYTHON_VENV

    source $OPENSTACK_PYTHON_VENV/bin/activate

    # Install Ansible, OpenStack client and SDK, latest openstack version supported is Train
    python -m pip install -U wheel
    python -m pip install -U "python-openstackclient<=4.0.2" "openstacksdk>=0.12.0,<=0.36.2" "ansible>=2.10,<2.11"

    # Install the Openstack cloud module (ansible>=2.10)
    ansible-galaxy collection install openstack.cloud

    export ANSIBLE_CONFIG="$OSM_DEVOPS/installers/openstack/ansible.cfg"

    OSM_INSTALLER_ARGS="${REPO_ARGS[@]}"

    ANSIBLE_VARS="external_network_name=$2 setup_volume=$3 server_name=$OPENSTACK_VM_NAME"

    if [ -n "$OPENSTACK_SSH_KEY_FILE" ]; then
        ANSIBLE_VARS+=" key_file=$OPENSTACK_SSH_KEY_FILE"
    fi

    if [ -n "$OPENSTACK_USERDATA_FILE" ]; then
        ANSIBLE_VARS+=" userdata_file=$OPENSTACK_USERDATA_FILE"
    fi

    # Execute the Ansible playbook based on openrc or clouds.yaml
    if [ -e "$1" ]; then
        . $1
        ansible-playbook -e installer_args="\"$OSM_INSTALLER_ARGS\"" -e "$ANSIBLE_VARS" \
        $OSM_DEVOPS/installers/openstack/site.yml
    else
        ansible-playbook -e installer_args="\"$OSM_INSTALLER_ARGS\"" -e "$ANSIBLE_VARS" \
        -e cloud_name=$1 $OSM_DEVOPS/installers/openstack/site.yml
    fi

    # Exit from venv
    deactivate

    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
    return 0
}

function arrange_docker_default_network_policy() {
    echo -e "Fixing firewall so docker and LXD can share the same host without affecting each other."
    sudo iptables -I DOCKER-USER -j ACCEPT
    sudo iptables-save | sudo tee /etc/iptables/rules.v4
    sudo ip6tables-save | sudo tee /etc/iptables/rules.v6
}

function install_k8s_monitoring() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    # install OSM monitoring
    sudo chmod +x $OSM_DEVOPS/installers/k8s/*.sh
    sudo $OSM_DEVOPS/installers/k8s/install_osm_k8s_monitoring.sh || FATAL_TRACK install_k8s_monitoring "k8s/install_osm_k8s_monitoring.sh failed"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function dump_vars(){
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    echo "APT_PROXY_URL=$APT_PROXY_URL"
    echo "DEVELOP=$DEVELOP"
    echo "DEBUG_INSTALL=$DEBUG_INSTALL"
    echo "DOCKER_NOBUILD=$DOCKER_NOBUILD"
    echo "DOCKER_PROXY_URL=$DOCKER_PROXY_URL"
    echo "DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL"
    echo "DOCKER_USER=$DOCKER_USER"
    echo "INSTALL_CACHELXDIMAGES=$INSTALL_CACHELXDIMAGES"
    echo "INSTALL_FROM_SOURCE=$INSTALL_FROM_SOURCE"
    echo "INSTALL_K8S_MONITOR=$INSTALL_K8S_MONITOR"
    echo "INSTALL_LIGHTWEIGHT=$INSTALL_LIGHTWEIGHT"
    echo "INSTALL_LXD=$INSTALL_LXD"
    echo "INSTALL_NGSA=$INSTALL_NGSA"
    echo "INSTALL_NODOCKER=$INSTALL_NODOCKER"
    echo "INSTALL_NOJUJU=$INSTALL_NOJUJU"
    echo "INSTALL_NOLXD=$INSTALL_NOLXD"
    echo "INSTALL_ONLY=$INSTALL_ONLY"
    echo "INSTALL_PLA=$INSTALL_PLA"
    echo "INSTALL_TO_OPENSTACK=$INSTALL_TO_OPENSTACK"
    echo "INSTALL_VIMEMU=$INSTALL_VIMEMU"
    echo "NO_HOST_PORTS=$NO_HOST_PORTS"
    echo "OPENSTACK_PUBLIC_NET_NAME=$OPENSTACK_PUBLIC_NET_NAME"
    echo "OPENSTACK_OPENRC_FILE_OR_CLOUD=$OPENSTACK_OPENRC_FILE_OR_CLOUD"
    echo "OPENSTACK_ATTACH_VOLUME=$OPENSTACK_ATTACH_VOLUME"
    echo "OPENSTACK_SSH_KEY_FILE"="$OPENSTACK_SSH_KEY_FILE"
    echo "OPENSTACK_USERDATA_FILE"="$OPENSTACK_USERDATA_FILE"
    echo "OPENSTACK_VM_NAME"="$OPENSTACK_VM_NAME"
    echo "OSM_DEVOPS=$OSM_DEVOPS"
    echo "OSM_DOCKER_TAG=$OSM_DOCKER_TAG"
    echo "OSM_DOCKER_WORK_DIR=$OSM_DOCKER_WORK_DIR"
    echo "OSM_HELM_WORK_DIR=$OSM_HELM_WORK_DIR"
    echo "OSM_K8S_WORK_DIR=$OSM_K8S_WORK_DIR"
    echo "OSM_STACK_NAME=$OSM_STACK_NAME"
    echo "OSM_VCA_HOST=$OSM_VCA_HOST"
    echo "OSM_VCA_PUBKEY=$OSM_VCA_PUBKEY"
    echo "OSM_VCA_SECRET=$OSM_VCA_SECRET"
    echo "OSM_WORK_DIR=$OSM_WORK_DIR"
    echo "PULL_IMAGES=$PULL_IMAGES"
    echo "RECONFIGURE=$RECONFIGURE"
    echo "RELEASE=$RELEASE"
    echo "REPOSITORY=$REPOSITORY"
    echo "REPOSITORY_BASE=$REPOSITORY_BASE"
    echo "REPOSITORY_KEY=$REPOSITORY_KEY"
    echo "SHOWOPTS=$SHOWOPTS"
    echo "TEST_INSTALLER=$TEST_INSTALLER"
    echo "TO_REBUILD=$TO_REBUILD"
    echo "UNINSTALL=$UNINSTALL"
    echo "UPDATE=$UPDATE"
    echo "Install from specific refspec (-b): $COMMIT_ID"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function parse_docker_registry_url() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    DOCKER_REGISTRY_USER=$(echo "$DOCKER_REGISTRY_URL" | awk '{split($1,a,"@"); split(a[1],b,":"); print b[1]}')
    DOCKER_REGISTRY_PASSWORD=$(echo "$DOCKER_REGISTRY_URL" | awk '{split($1,a,"@"); split(a[1],b,":"); print b[2]}')
    DOCKER_REGISTRY_URL=$(echo "$DOCKER_REGISTRY_URL" | awk '{split($1,a,"@"); print a[2]}')
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

function ctrl_c() {
    [ -z "${DEBUG_INSTALL}" ] || DEBUG beginning of function
    echo "** Trapped CTRL-C"
    FATAL "User stopped the installation"
    [ -z "${DEBUG_INSTALL}" ] || DEBUG end of function
}

UNINSTALL=""
DEVELOP=""
UPDATE=""
RECONFIGURE=""
TEST_INSTALLER=""
INSTALL_LXD=""
SHOWOPTS=""
COMMIT_ID="v13.0"
ASSUME_YES=""
APT_PROXY_URL=""
INSTALL_FROM_SOURCE=""
DEBUG_INSTALL=""
RELEASE="ReleaseTEN"
REPOSITORY="stable"
INSTALL_K8S_MONITOR=""
INSTALL_NGSA=""
INSTALL_PLA=""
INSTALL_VIMEMU=""
LXD_REPOSITORY_BASE="https://osm-download.etsi.org/repository/osm/lxd"
LXD_REPOSITORY_PATH=""
INSTALL_LIGHTWEIGHT="y"
INSTALL_TO_OPENSTACK=""
OPENSTACK_OPENRC_FILE_OR_CLOUD=""
OPENSTACK_PUBLIC_NET_NAME=""
OPENSTACK_ATTACH_VOLUME="false"
OPENSTACK_SSH_KEY_FILE=""
OPENSTACK_USERDATA_FILE=""
OPENSTACK_VM_NAME="server-osm"
OPENSTACK_PYTHON_VENV="$HOME/.virtual-envs/osm"
INSTALL_ONLY=""
TO_REBUILD=""
INSTALL_NOLXD=""
INSTALL_NODOCKER=""
INSTALL_NOJUJU=""
INSTALL_NOHOSTCLIENT=""
INSTALL_CACHELXDIMAGES=""
OSM_DEVOPS=
OSM_VCA_HOST=
OSM_VCA_SECRET=
OSM_VCA_PUBKEY=
OSM_VCA_CLOUDNAME="localhost"
OSM_VCA_K8S_CLOUDNAME="k8scloud"
OSM_STACK_NAME=osm
NO_HOST_PORTS=""
DOCKER_NOBUILD=""
REPOSITORY_KEY="OSM%20ETSI%20Release%20Key.gpg"
REPOSITORY_BASE="https://osm-download.etsi.org/repository/osm/debian"
OSM_WORK_DIR="/etc/osm"
OSM_DOCKER_WORK_DIR="${OSM_WORK_DIR}/docker"
OSM_K8S_WORK_DIR="${OSM_DOCKER_WORK_DIR}/osm_pods"
OSM_HELM_WORK_DIR="${OSM_WORK_DIR}/helm"
OSM_HOST_VOL="/var/lib/osm"
OSM_NAMESPACE_VOL="${OSM_HOST_VOL}/${OSM_STACK_NAME}"
OSM_DOCKER_TAG=13
DOCKER_USER=opensourcemano
PULL_IMAGES="y"
KAFKA_TAG=2.11-1.0.2
KIWIGRID_K8S_SIDECAR_TAG="1.15.6"
PROMETHEUS_TAG=v2.28.1
GRAFANA_TAG=8.1.1
PROMETHEUS_NODE_EXPORTER_TAG=0.18.1
PROMETHEUS_CADVISOR_TAG=latest
KEYSTONEDB_TAG=10
OSM_DATABASE_COMMONKEY=
ELASTIC_VERSION=6.4.2
ELASTIC_CURATOR_VERSION=5.5.4
POD_NETWORK_CIDR=10.244.0.0/16
K8S_MANIFEST_DIR="/etc/kubernetes/manifests"
RE_CHECK='^[a-z0-9]([-a-z0-9]*[a-z0-9])?$'
DOCKER_REGISTRY_URL=
DOCKER_PROXY_URL=
MODULE_DOCKER_TAG=
OSM_INSTALLATION_TYPE="Default"

while getopts ":a:b:r:n:k:u:R:D:o:O:m:N:H:S:s:t:U:P:A:l:L:K:d:p:T:f:F:-: hy" o; do
    case "${o}" in
        a)
            APT_PROXY_URL=${OPTARG}
            ;;
        b)
            COMMIT_ID=${OPTARG}
            PULL_IMAGES=""
            ;;
        r)
            REPOSITORY="${OPTARG}"
            REPO_ARGS+=(-r "$REPOSITORY")
            ;;
        k)
            REPOSITORY_KEY="${OPTARG}"
            REPO_ARGS+=(-k "$REPOSITORY_KEY")
            ;;
        u)
            REPOSITORY_BASE="${OPTARG}"
            REPO_ARGS+=(-u "$REPOSITORY_BASE")
            ;;
        R)
            RELEASE="${OPTARG}"
            REPO_ARGS+=(-R "$RELEASE")
            ;;
        D)
            OSM_DEVOPS="${OPTARG}"
            ;;
        o)
            INSTALL_ONLY="y"
            [ "${OPTARG}" == "k8s_monitor" ] && INSTALL_K8S_MONITOR="y" && continue
            [ "${OPTARG}" == "ng-sa" ] && INSTALL_NGSA="y" && continue
            ;;
        O)
            INSTALL_TO_OPENSTACK="y"
            if [ -n "${OPTARG}" ]; then
                OPENSTACK_OPENRC_FILE_OR_CLOUD="${OPTARG}"
            else
                echo -e "Invalid argument for -O : ' $OPTARG'\n" >&2
                usage && exit 1
            fi
            ;;
        f)
            OPENSTACK_SSH_KEY_FILE="${OPTARG}"
            ;;
        F)
            OPENSTACK_USERDATA_FILE="${OPTARG}"
            ;;
        N)
            OPENSTACK_PUBLIC_NET_NAME="${OPTARG}"
            ;;
        m)
            [ "${OPTARG}" == "NG-UI" ] && TO_REBUILD="$TO_REBUILD NG-UI" && continue
            [ "${OPTARG}" == "NBI" ] && TO_REBUILD="$TO_REBUILD NBI" && continue
            [ "${OPTARG}" == "LCM" ] && TO_REBUILD="$TO_REBUILD LCM" && continue
            [ "${OPTARG}" == "RO" ] && TO_REBUILD="$TO_REBUILD RO" && continue
            [ "${OPTARG}" == "MON" ] && TO_REBUILD="$TO_REBUILD MON" && continue
            [ "${OPTARG}" == "POL" ] && TO_REBUILD="$TO_REBUILD POL" && continue
            [ "${OPTARG}" == "PLA" ] && TO_REBUILD="$TO_REBUILD PLA" && continue
            [ "${OPTARG}" == "osmclient" ] && TO_REBUILD="$TO_REBUILD osmclient" && continue
            [ "${OPTARG}" == "KAFKA" ] && TO_REBUILD="$TO_REBUILD KAFKA" && continue
            [ "${OPTARG}" == "MONGO" ] && TO_REBUILD="$TO_REBUILD MONGO" && continue
            [ "${OPTARG}" == "PROMETHEUS" ] && TO_REBUILD="$TO_REBUILD PROMETHEUS" && continue
            [ "${OPTARG}" == "PROMETHEUS-CADVISOR" ] && TO_REBUILD="$TO_REBUILD PROMETHEUS-CADVISOR" && continue
            [ "${OPTARG}" == "KEYSTONE-DB" ] && TO_REBUILD="$TO_REBUILD KEYSTONE-DB" && continue
            [ "${OPTARG}" == "GRAFANA" ] && TO_REBUILD="$TO_REBUILD GRAFANA" && continue
            [ "${OPTARG}" == "NONE" ] && TO_REBUILD="$TO_REBUILD NONE" && continue
            ;;
        H)
            OSM_VCA_HOST="${OPTARG}"
            ;;
        S)
            OSM_VCA_SECRET="${OPTARG}"
            ;;
        s)
            OSM_STACK_NAME="${OPTARG}" && [[ ! "${OPTARG}" =~ $RE_CHECK ]] && echo "Namespace $OPTARG is invalid. Regex used for validation is $RE_CHECK" && exit 0
            ;;
        t)
            OSM_DOCKER_TAG="${OPTARG}"
            REPO_ARGS+=(-t "$OSM_DOCKER_TAG")
            ;;
        U)
            DOCKER_USER="${OPTARG}"
            ;;
        P)
            OSM_VCA_PUBKEY=$(cat ${OPTARG})
            ;;
        A)
            OSM_VCA_APIPROXY="${OPTARG}"
            ;;
        l)
            LXD_CLOUD_FILE="${OPTARG}"
            ;;
        L)
            LXD_CRED_FILE="${OPTARG}"
            ;;
        K)
            CONTROLLER_NAME="${OPTARG}"
            ;;
        d)
            DOCKER_REGISTRY_URL="${OPTARG}"
            ;;
        p)
            DOCKER_PROXY_URL="${OPTARG}"
            ;;
        T)
            MODULE_DOCKER_TAG="${OPTARG}"
            ;;
        -)
            [ "${OPTARG}" == "help" ] && usage && exit 0
            [ "${OPTARG}" == "source" ] && INSTALL_FROM_SOURCE="y" && PULL_IMAGES="" && continue
            [ "${OPTARG}" == "debug" ] && DEBUG_INSTALL="--debug" && continue
            [ "${OPTARG}" == "develop" ] && DEVELOP="y" && continue
            [ "${OPTARG}" == "uninstall" ] && UNINSTALL="y" && continue
            [ "${OPTARG}" == "update" ] && UPDATE="y" && continue
            [ "${OPTARG}" == "reconfigure" ] && RECONFIGURE="y" && continue
            [ "${OPTARG}" == "test" ] && TEST_INSTALLER="y" && continue
            [ "${OPTARG}" == "lxdinstall" ] && INSTALL_LXD="y" && continue
            [ "${OPTARG}" == "nolxd" ] && INSTALL_NOLXD="y" && continue
            [ "${OPTARG}" == "nodocker" ] && INSTALL_NODOCKER="y" && continue
            [ "${OPTARG}" == "showopts" ] && SHOWOPTS="y" && continue
            [ "${OPTARG}" == "nohostports" ] && NO_HOST_PORTS="y" && continue
            [ "${OPTARG}" == "nojuju" ] && INSTALL_NOJUJU="--nojuju" && continue
            [ "${OPTARG}" == "nodockerbuild" ] && DOCKER_NOBUILD="y" && continue
            [ "${OPTARG}" == "nohostclient" ] && INSTALL_NOHOSTCLIENT="y" && continue
            [ "${OPTARG}" == "pullimages" ] && continue
            [ "${OPTARG}" == "k8s_monitor" ] && INSTALL_K8S_MONITOR="y" && continue
            [ "${OPTARG}" == "charmed" ] && CHARMED="y" && OSM_INSTALLATION_TYPE="Charmed" && continue
            [ "${OPTARG}" == "bundle" ] && continue
            [ "${OPTARG}" == "k8s" ] && continue
            [ "${OPTARG}" == "lxd" ] && continue
            [ "${OPTARG}" == "lxd-cred" ] && continue
            [ "${OPTARG}" == "microstack" ] && continue
            [ "${OPTARG}" == "overlay" ] && continue
            [ "${OPTARG}" == "only-vca" ] && continue
            [ "${OPTARG}" == "small-profile" ] && continue
            [ "${OPTARG}" == "vca" ] && continue
            [ "${OPTARG}" == "ha" ] && continue
            [ "${OPTARG}" == "tag" ] && continue
            [ "${OPTARG}" == "registry" ] && continue
            [ "${OPTARG}" == "pla" ] && INSTALL_PLA="y" && continue
            [ "${OPTARG}" == "ng-sa" ] && INSTALL_NGSA="y" && continue
            [ "${OPTARG}" == "volume" ] && OPENSTACK_ATTACH_VOLUME="true" && continue
            [ "${OPTARG}" == "nocachelxdimages" ] && continue
            [ "${OPTARG}" == "cachelxdimages" ] && INSTALL_CACHELXDIMAGES="--cachelxdimages" && continue
            echo -e "Invalid option: '--$OPTARG'\n" >&2
            usage && exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            usage && exit 1
            ;;
        \?)
            echo -e "Invalid option: '-$OPTARG'\n" >&2
            usage && exit 1
            ;;
        h)
            usage && exit 0
            ;;
        y)
            ASSUME_YES="y"
            ;;
        *)
            usage && exit 1
            ;;
    esac
done

source $OSM_DEVOPS/common/all_funcs

[ -z "${DEBUG_INSTALL}" ] || DEBUG Debug is on
[ -n "$SHOWOPTS" ] && dump_vars && exit 0

# Uninstall if "--uninstall"
if [ -n "$UNINSTALL" ]; then
    if [ -n "$CHARMED" ]; then
        ${OSM_DEVOPS}/installers/charmed_uninstall.sh -R $RELEASE -r $REPOSITORY -u $REPOSITORY_BASE -D $OSM_DEVOPS -t $DOCKER_TAG "$@" || \
        FATAL_TRACK charmed_uninstall "charmed_uninstall.sh failed"
    else
        ${OSM_DEVOPS}/installers/uninstall_osm.sh "$@" || \
        FATAL_TRACK community_uninstall "uninstall_osm.sh failed"
    fi
    echo -e "\nDONE"
    exit 0
fi

# Charmed installation
if [ -n "$CHARMED" ]; then
    sudo snap install jq || FATAL "Could not install jq (snap package). Make sure that snap works"
    export OSM_TRACK_INSTALLATION_ID="$(date +%s)-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)"
    track start release $RELEASE none none docker_tag $OSM_DOCKER_TAG none none installation_type $OSM_INSTALLATION_TYPE none none
    ${OSM_DEVOPS}/installers/charmed_install.sh --tag $OSM_DOCKER_TAG "$@" || \
    FATAL_TRACK charmed_install "charmed_install.sh failed"
    wget -q -O- https://osm-download.etsi.org/ftp/osm-13.0-thirteen/README2.txt &> /dev/null
    track end installation_type $OSM_INSTALLATION_TYPE
    echo -e "\nDONE"
    exit 0
fi

# Installation to Openstack
if [ -n "$INSTALL_TO_OPENSTACK" ]; then
    install_to_openstack $OPENSTACK_OPENRC_FILE_OR_CLOUD $OPENSTACK_PUBLIC_NET_NAME $OPENSTACK_ATTACH_VOLUME
    echo -e "\nDONE"
    exit 0
fi

# Community_installer

[ -n "$TO_REBUILD" ] && [ "$TO_REBUILD" != " NONE" ] && echo $TO_REBUILD | grep -q NONE && FATAL "Incompatible option: -m NONE cannot be used with other -m options"
[ -n "$TO_REBUILD" ] && [ "$TO_REBUILD" == " PLA" ] && [ -z "$INSTALL_PLA" ] && FATAL "Incompatible option: -m PLA cannot be used without --pla option"
# if develop, we force master
[ -z "$COMMIT_ID" ] && [ -n "$DEVELOP" ] && COMMIT_ID="master"
OSM_K8S_WORK_DIR="$OSM_DOCKER_WORK_DIR/osm_pods" && OSM_NAMESPACE_VOL="${OSM_HOST_VOL}/${OSM_STACK_NAME}"
[ -n "$INSTALL_ONLY" ] && [ -n "$INSTALL_K8S_MONITOR" ] && install_k8s_monitoring
[ -n "$INSTALL_ONLY" ] && [ -n "$INSTALL_NGSA" ] && install_osm_ngsa_service
[ -n "$INSTALL_ONLY" ] && echo -e "\nDONE" && exit 0

#Installation starts here
wget -q -O- https://osm-download.etsi.org/ftp/osm-13.0-thirteen/README.txt &> /dev/null
export OSM_TRACK_INSTALLATION_ID="$(date +%s)-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)"
install_osm
echo -e "\nDONE"
exit 0

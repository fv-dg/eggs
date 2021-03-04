# startup script for discordPHP egg
if [[ -d .git ]] && [[ {{AUTO_UPDATE}} == "1" ]]; then git pull; fi; if [ -f /home/container/composer.lock ]; then composer install; elif [ -f /home/container/composer.json ]; then composer install; fi; php /home/container/{{PHP_INDEX_FILE}}

# install script for discordPHP egg
apt update
apt install -y git make gcc g++ libtool zip unzip
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

mkdir -p /mnt/server
cd /mnt/server

installl() {
    URL=$1
    if [ "$(ls -A /mnt/server)" ]; then
        
        echo -e "/mnt/server directory is not empty."
        if [ -d .git ]; then
        
            echo -e ".git directory exists"
            if [ -f .git/config ]; then
                
                echo -e "loading info from git config"
                ORIGIN=$(git config --get remote.origin.url)
                if [ "${ORIGIN}" == "${URL}.git" ]; then
                    echo "pulling latest from github"   
                    git pull
                fi

            else
                
                echo -e "files found with no git config"
                echo -e "closing out without touching things to not break anything"
                exit 10
            fi
        fi
    else
        echo -e "new installation detected, cloning from github repo for first time."
        echo -e "running 'git clone --single-branch --branch ${INSTALL_BRANCH} ${URL}.git .'"
        git clone --single-branch --branch ${INSTALL_BRANCH} ${URL}.git .
    fi
}

if [ "${USER_UPLOAD}" == "true" ] || [ "${USER_UPLOAD}" == "1" ]; then
    echo -e "assuming user knows what they are doing have a good day."
    exit 0
fi

if [ "${USERNAME}" == "" ]; then
    echo -e "username not set, assuming public repo."
    installl "https://github.com/${INSTALL_REPO}"
else
    echo -e "atempting to clone from private repo with provided credentials."
    installl "https://${USERNAME}:${PASSWORD}@github.com/${INSTALL_REPO}"
fi

echo "Installing composer dependencies into folder"
if [[ ! -z ${DEPENDENCIES} ]]; then
    /usr/local/bin/composer install ${DEPENDENCIES}
fi

if [ -f /mnt/server/composer.json ]; then
    /usr/local/bin/composer install
fi

echo -e "install complete"
exit 0

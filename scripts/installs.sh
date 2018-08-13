#!/usr/bin/env bash

# Docker
mu_installs::docker_ce::preinstall() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
}
mu_installs::docker_ce::install() {
  sudo apt-get install -y docker-ce
}
mu_installs::docker_io::install() {
  sudo apt-get install -y docker.io
}
mu_installs::docker::preinstall() {
  mu_installs::docker_ce::preinstall
}
mu_installs::docker::install() {
  mu_installs::docker_ce::install
}
mu_installs::docker::configure::group_add_user() {
  sudo usermod -a -G docker "$1"
}
mu_installs::docker::configure::cn-mirrors() {
  sudo tee -a /etc/docker/daemon.json << END
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
END
}

# Docker Compose
mu_installs::docker_compose::install() {
  DOCKER_COMPOSE_VER=$(mu:git_latest_release docker/compose)
  sudo curl -L https://github.com/docker/compose/releases/download/"$DOCKER_COMPOSE_VER"/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}
# Docker Machine
mu_installs::docker_machine::install() {
  DOCKER_MACHINE_VER=$(mu:git_latest_release docker/machine)
  sudo curl -L https://github.com/docker/machine/releases/download/"$DOCKER_MACHINE_VER"/docker-machine-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-machine
  sudo chmod +x /usr/local/bin/docker-machine
}

# Google Chrome Stable
mu_installs::google_chrome_stable::preinstall() {
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
}
mu_installs::google_chrome_stable::install() {
  sudo apt-get install -y google-chrome-stable
}

# Visual Studio Code
mu_installs::visual_studio_code::preinstall() {
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg && {
      sudo mv /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
      sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  }
}
mu_installs::visual_studio_code::install() {
  sudo apt-get install -y code
}
mu_installs::visual_studio_code::configure() {
  code --version && {
    echo |sudo tee -a /etc/sysctl.conf
    echo "# Make vscode watch more files"|sudo tee -a /etc/sysctl.conf
    echo "fs.inotify.max_user_watches=524288"|sudo tee -a /etc/sysctl.conf
    echo |sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
  }
}

# Indicator Netspeed Unity
mu_installs::indicator_netspeed::preinstall() {
  sudo add-apt-repository -y ppa:fixnix/netspeed
}
mu_installs::indicator_netspeed::install() {
  sudo apt-get install -y indicator-netspeed-unity
}

# Numix Theme
mu_installs::numix_theme::preinstall() {
  sudo add-apt-repository -y ppa:numix/ppa
}
mu_installs::numix_theme::install() {
  sudo apt-get install -y numix-gtk-theme
}

# Open Broadcaster Software
mu_installs::obs::preinstall() {
  sudo add-apt-repository -y ppa:obsproject/obs-studio
}
mu_installs::obs::install() {
  sudo apt-get install obs-studio
}

# Node JS
mu_installs::node::install() {
  sudo apt-get install build-essential
  curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
}
mu_installs::node::configure() {
  node --version && {
    mkdir -p "$HOME"/.npm-global/{lib/node_modules,bin,shell}
    npm config set prefix "$HOME/.npm-global"

    echo >>"$HOME/.profile"
    echo "PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$HOME/.profile"

    source "$HOME/.profile"
  }
}

# Yarn
mu_installs::yarn::preinstall() {
  sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
}
mu_installs::yarn::install() {
  sudo apt-get install yarn
}

# Fcitx
mu_installs::fcitx::install() {
  sudo apt-get install -y fcitx fcitx-googlepinyin
}
mu_installs::fcitx::personalise() {
  sudo curl -L "$ARCHIVE_PREFIX/ubuntu-personalise/fcitx/geek-dark.tar.gz" -o /tmp/geek-dark.tar.gz && {
    sudo tar -xzf /tmp/geek-dark.tar.gz -C /usr/share/fcitx/skin/
    
    sudo chown -R root:root /usr/share/fcitx/skin/geek-dark
    sudo chmod 755 /usr/share/fcitx/skin/geek-dark
    sudo chmod 644 /usr/share/fcitx/skin/geek-dark/*
  }
}

# Inziu Iosevka Font
mu_installs::iosevka::install() {
  IOSEVKA_VER=$(mu:git_latest_release be5invis/Iosevka | sed 's/v//')
  IOSEVKA_URL="https://github.com/be5invis/Iosevka/releases/download/v$IOSEVKA_VER/02-iosevka-term-$IOSEVKA_VER.zip"

  wget -O /tmp/iosevka.zip "$IOSEVKA_URL" && {
    mkdir -p /tmp/iosevka
    unzip /tmp/iosevka.zip -d /tmp/iosevka

    sudo mkdir -p /usr/share/fonts/InziuIosevka
    sudo mv /tmp/iosevka/ttf/* /usr/share/fonts/InziuIosevka
    sudo chmod 755 /usr/share/fonts/InziuIosevka
    sudo chmod 644 /usr/share/fonts/InziuIosevka/*
    sudo fc-cache -fv
  }
}

# ZSH
mu_installs::zsh::install() {
  sudo apt-get install -y zsh && \
  su "$USER" -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}
mu_installs::zsh::personalise() {
  wget -O "$HOME/.zshrc" "$ARCHIVE_PREFIX/zsh/.zshrc"
}
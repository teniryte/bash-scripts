#!/bin/bash

# Проверка прав администратора
if [ "$EUID" -ne 0 ]; then
    echo "Для выполнения требуется root-доступ. Запустите скрипт с sudo."
    exit 1
fi

# Определение типа ОС
if [ -f /etc/os-release ]; then
    source /etc/os-release
    case $ID in
        debian|ubuntu) os_type="debian" ;;
        centos|rhel|ol) os_type="centos" ;;
        *) echo "Неподдерживаемая ОС"; exit 1 ;;
    esac
else
    echo "Не удалось определить ОС"
    exit 1
fi

# Установка зависимостей
echo "Установка зависимостей..."
if [ "$os_type" = "debian" ]; then
    apt update -y
    apt install -y curl openssh-server ca-certificates
elif [ "$os_type" = "centos" ]; then
    yum install -y curl policycoreutils openssh-server openssh-clients
fi

# Добавление репозитория GitLab
echo "Добавление репозитория GitLab..."
if [ "$os_type" = "debian" ]; then
    curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
elif [ "$os_type" = "centos" ]; then
    curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash
fi

# Установка GitLab CE
echo "Установка GitLab CE..."
if [ "$os_type" = "debian" ]; then
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y gitlab-ce
elif [ "$os_type" = "centos" ]; then
    yum makecache
    yum install -y gitlab-ce
fi

# Настройка GitLab
echo "Запуск финальной настройки..."
gitlab-ctl reconfigure

echo "Установка GitLab CE завершена!"
echo "Вы можете получить root-пароль командой:"
echo "sudo cat /etc/gitlab/initial_root_password"

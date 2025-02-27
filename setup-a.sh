#!/bin/bash

# Определение цветов
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color (сброс цвета)

# Функция для вывода меню
show_menu() {
    echo -e "${BLUE}Выберите пункт меню:${NC}"
    echo -e "1. ${YELLOW}Обновить /etc/apt/sources.list и обновить систему${NC}"
    echo -e "2. ${YELLOW}Установить необходимые пакеты${NC}"
    echo -e "3. ${YELLOW}Настроить сеть${NC}"
    echo -e "4. ${YELLOW}Создать нового пользователя${NC}"
    echo -e "5. ${YELLOW}Создать каталог /media/shared/common и настроить права${NC}"
    echo -e "6. ${YELLOW}Создать файл .windowscredentials для монтирования сетевого каталога${NC}"
    echo -e "7. ${YELLOW}Настроить монтирование сетевой папки в /etc/fstab${NC}"
    echo -e "8. ${YELLOW}Установить КриптоПро CSP (только КС1, без КС2)${NC}"
    echo -e "9. ${YELLOW}Выполнить все пункты${NC}"
    echo -e "10. ${YELLOW}Выйти${NC}"
}

# Функция для обновления /etc/apt/sources.list
update_sources_list() {
    echo -e "${BLUE}Обновление /etc/apt/sources.list...${NC}"
    sudo bash -c 'cat > /etc/apt/sources.list <<EOF
# Основной репозиторий, включающий актуальное оперативное или срочное обновление
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/main-repository/     1.8_x86-64 main contrib non-free non-free-firmware
# Расширенный репозиторий, соответствующий актуальному оперативному обновлению
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/extended-repository/ 1.8_x86-64 main contrib non-free non-free-firmware
EOF'
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Файл /etc/apt/sources.list обновлен.${NC}"
    else
        echo -e "${RED}Ошибка при обновлении /etc/apt/sources.list.${NC}"
    fi
}

# Функция для обновления системы с использованием astra-update
update_system() {
    echo -e "${BLUE}Обновление системы...${NC}"
    sudo apt update
    sudo astra-update -A -r
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Обновление системы завершено.${NC}"
    else
        echo -e "${RED}Ошибка при обновлении системы.${NC}"
    fi
}

# Функция для установки необходимых пакетов
install_packages() {
    echo -e "${BLUE}Установка пакетов...${NC}"
    sudo apt-get install -y curl git vim cifs-utils
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Установка пакетов (включая cifs-utils) завершена.${NC}"
    else
        echo -e "${RED}Ошибка при установке пакетов. Проверьте интернет или репозитории.${NC}"
    fi
}

# Функция для настройки сети
configure_network() {
    echo -e "${BLUE}Настройка сети...${NC}"
    echo "search example.com" | sudo tee -a /etc/resolv.conf > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Настройка сети завершена (домен поиска: example.com).${NC}"
    else
        echo -e "${RED}Ошибка при настройке сети.${NC}"
    fi
}

# Функция для создания нового пользователя
create_user() {
    echo -e "${BLUE}Создание нового пользователя...${NC}"

    echo -e -n "${YELLOW}Введите полное имя пользователя: ${NC}"
    read full_name

    echo -e -n "${YELLOW}Введите логин пользователя: ${NC}"
    read username

    echo -e -n "${YELLOW}Введите пароль для пользователя $username: ${NC}"
    read -s password
    echo

    sudo useradd -m -c "$full_name" -s /bin/bash "$username"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Пользователь $username успешно создан.${NC}"
    else
        echo -e "${RED}Ошибка при создании пользователя $username.${NC}"
        return 1
    fi

    echo "$username:$password" | sudo chpasswd
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Пароль для пользователя $username успешно установлен.${NC}"
    else
        echo -e "${RED}Ошибка при установке пароля для пользователя $username.${NC}"
    fi

    if ! getent group gau-user > /dev/null; then
        sudo groupadd gau-user
        echo -e "${GREEN}Группа gau-user создана.${NC}"
    else
        echo -e "${YELLOW}Группа gau-user уже существует.${NC}"
    fi

    sudo usermod -aG gau-user "$username"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Пользователь $username добавлен в группу gau-user.${NC}"
    else
        echo -e "${RED}Ошибка при добавлении пользователя $username в группу gau-user.${NC}"
    fi
}

# Функция для создания каталога и настройки прав
setup_shared_directory() {
    echo -e "${BLUE}Создание каталога /media/shared/common и настройка прав...${NC}"

    if [ ! -d "/media/shared/common" ]; then
        sudo mkdir -p "/media/shared/common"
        echo -e "${GREEN}Каталог /media/shared/common создан.${NC}"
    else
        echo -e "${YELLOW}Каталог /media/shared/common уже существует.${NC}"
    fi

    sudo chown root:gau-user /media/shared/common
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Владелец каталога изменен на root:gau-user.${NC}"
    else
        echo -e "${RED}Ошибка при смене владельца каталога.${NC}"
    fi

    sudo chmod 775 /media/shared/common
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Права на каталог установлены: владелец и группа имеют полный доступ, остальные — чтение и выполнение.${NC}"
    else
        echo -e "${RED}Ошибка при установке прав на каталог.${NC}"
    fi
}

# Функция для создания файла .windowscredentials
setup_windows_credentials() {
    echo -e "${BLUE}Создание файла .windowscredentials для монтирования сетевого каталога...${NC}"

    users=($(getent passwd | grep -E "/home" | cut -d: -f1))
    if [ ${#users[@]} -eq 0 ]; then
        echo -e "${RED}Нет активных пользователей с домашними каталогами.${NC}"
        return 1
    fi

    echo -e "${BLUE}Список активных пользователей:${NC}"
    for i in "${!users[@]}"; do
        echo -e "$((i+1)). ${YELLOW}${users[$i]}${NC}"
    done

    echo -e -n "${YELLOW}Выберите пользователя (введите номер): ${NC}"
    read user_choice
    if [[ ! $user_choice =~ ^[0-9]+$ ]] || [ $user_choice -lt 1 ] || [ $user_choice -gt ${#users[@]} ]; then
        echo -e "${RED}Неверный выбор.${NC}"
        return 1
    fi

    selected_user="${users[$((user_choice-1))]}"
    home_dir=$(getent passwd "$selected_user" | cut -d: -f6)

    credentials_file="$home_dir/.windowscredentials"
    echo -e "${BLUE}Создание файла $credentials_file...${NC}"

    echo -e -n "${YELLOW}Введите имя пользователя Windows: ${NC}"
    read win_user
    echo -e -n "${YELLOW}Введите пароль пользователя Windows: ${NC}"
    read -s win_password
    echo

    sudo bash -c "cat > $credentials_file <<EOF
username=$win_user
password=$win_password
domain=expnet.ru
EOF"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Файл $credentials_file успешно создан с доменными учетными данными.${NC}"
    else
        echo -e "${RED}Ошибка при создании файла $credentials_file.${NC}"
        return 1
    fi

    sudo chown "$selected_user:$selected_user" "$credentials_file"
    sudo chmod 600 "$credentials_file"
    echo -e "${GREEN}Права на файл установлены: только владелец может читать и писать.${NC}"
}

# Функция для настройки монтирования сетевой папки в /etc/fstab
setup_network_mount() {
    echo -e "${BLUE}Настройка монтирования сетевой папки в /etc/fstab...${NC}"

    if ! dpkg -l | grep -q cifs-utils; then
        echo -e "${RED}Пакет cifs-utils не установлен. Устанавливаем...${NC}"
        sudo apt-get update
        sudo apt-get install -y cifs-utils
        if [ $? -ne 0 ]; then
            echo -e "${RED}Не удалось установить cifs-utils. Проверьте интернет или репозитории.${NC}"
            return 1
        fi
        echo -e "${GREEN}Пакет cifs-utils успешно установлен.${NC}"
        echo -e -n "${YELLOW}Требуется перезагрузка для активации CIFS. Перезагрузить сейчас? (y/n): ${NC}"
        read reboot_choice
        if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
            sudo reboot
        else
            echo -e "${YELLOW}Перезагрузка отложена. Пожалуйста, перезагрузите систему вручную для завершения настройки.${NC}"
            return 0
        fi
    else
        echo -e "${YELLOW}Пакет cifs-utils уже установлен.${NC}"
    fi

    if ! lsmod | grep -q cifs && ! modprobe cifs 2>/dev/null; then
        echo -e "${RED}Модуль CIFS не найден в ядре. Попытка установить дополнительные модули...${NC}"
        sudo apt-get update
        sudo apt-get install -y linux-modules-extra-$(uname -r)
        if [ $? -eq 0 ]; then
            sudo modprobe cifs
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Модуль CIFS успешно загружен.${NC}"
                echo -e -n "${YELLOW}Требуется перезагрузка для активации модуля CIFS. Перезагрузить сейчас? (y/n): ${NC}"
                read reboot_choice
                if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
                    sudo reboot
                else
                    echo -e "${YELLOW}Перезагрузка отложена. Пожалуйста, перезагрузите систему вручную для завершения настройки.${NC}"
                    return 0
                fi
            else
                echo -e "${RED}Не удалось загрузить модуль CIFS. Возможно, нужно обновить ядро.${NC}"
                return 1
            fi
        else
            echo -e "${RED}Не удалось установить linux-modules-extra. Проверьте репозитории.${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Поддержка CIFS уже доступна.${NC}"
    fi

    users=($(getent passwd | grep -E "/home" | cut -d: -f1))
    if [ ${#users[@]} -eq 0 ]; then
        echo -e "${RED}Нет активных пользователей с домашними каталогами.${NC}"
        return 1
    fi

    echo -e "${BLUE}Список активных пользователей:${NC}"
    for i in "${!users[@]}"; do
        echo -e "$((i+1)). ${YELLOW}${users[$i]}${NC}"
    done

    echo -e -n "${YELLOW}Выберите пользователя (введите номер): ${NC}"
    read user_choice
    if [[ ! $user_choice =~ ^[0-9]+$ ]] || [ $user_choice -lt 1 ] || [ $user_choice -gt ${#users[@]} ]; then
        echo -e "${RED}Неверный выбор.${NC}"
        return 1
    fi

    selected_user="${users[$((user_choice-1))]}"
    home_dir=$(getent passwd "$selected_user" | cut -d: -f6)
    credentials_file="$home_dir/.windowscredentials"

    if [ ! -f "$credentials_file" ]; then
        echo -e "${RED}Файл $credentials_file не найден. Сначала создайте его в пункте 6.${NC}"
        return 1
    fi

    share_path="//server-ad.expnet.ru/Common"
    mount_point="/media/shared/common"

    if [ ! -d "$mount_point" ]; then
        sudo mkdir -p "$mount_point"
        echo -e "${GREEN}Точка монтирования $mount_point создана.${NC}"
    else
        echo -e "${YELLOW}Точка монтирования $mount_point уже существует.${NC}"
    fi

    fstab_entry="$share_path $mount_point cifs user,nofail,credentials=$credentials_file,iocharset=utf8,file_mode=0777,dir_mode=0777 0 0"
    if ! grep -Fxq "$fstab_entry" /etc/fstab; then
        echo "$fstab_entry" | sudo tee -a /etc/fstab > /dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Сетевая папка $share_path добавлена в /etc/fstab для монтирования в $mount_point.${NC}"
        else
            echo -e "${RED}Ошибка при добавлении записи в /etc/fstab.${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Запись для $share_path уже существует в /etc/fstab.${NC}"
    fi

    echo -e "${BLUE}Тестирование монтирования сетевой папки...${NC}"
    sudo mount -a
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Сетевая папка успешно смонтирована в $mount_point.${NC}"
    else
        echo -e "${RED}Ошибка при монтировании сетевой папки. Проверьте dmesg или параметры монтирования.${NC}"
    fi
}

# Функция для установки КриптоПро CSP (только КС1, без КС2)
install_cryptopro() {
    echo -e "${BLUE}Установка КриптоПро CSP (только КС1, без КС2)...${NC}"

    # Проверка наличия установленного КриптоПро
    if command -v cprocsp-uninstall.sh &>/dev/null; then
        echo -e "${YELLOW}КриптоПро CSP уже установлен на системе.${NC}"
        return 0
    fi

    # Установка необходимых пакетов для КриптоПро
    echo -e "${BLUE}Установка необходимых пакетов для КриптоПро CSP...${NC}"
    sudo apt update
    sudo apt install -y whiptail libccid pcscd libpcsclite1 opensc libengine-pkcs11-openssl*
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке необходимых пакетов для КриптоПро. Проверьте интернет или репозитории.${NC}"
        return 1
    fi
    echo -e "${GREEN}Необходимые пакеты для КриптоПро успешно установлены.${NC}"

    # Проверка наличия архiva linux-amd64_deb.tgz
    cryptopro_archive="linux-amd64_deb.tgz"
    if [ ! -f "$cryptopro_archive" ]; then
        echo -e "${RED}Архив $cryptopro_archive не найден в текущей директории.${NC}"
        echo -e "${YELLOW}Пожалуйста, скачайте дистрибутив КриптоПро CSP версии 4.0 (только КС1, без КС2) с сайта cryptopro.ru (раздел 'Центр загрузки') и поместите его в текущую директорию как 'linux-amd64_deb.tgz'.${NC}"
        return 1
    fi

    # Распаковка архива
    echo -e "${BLUE}Распаковка архива $cryptopro_archive...${NC}"
    sudo tar -xzf "$cryptopro_archive"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при распаковке архива КриптоПро.${NC}"
        return 1
    fi

    # Определение имени распакованной директории
    cryptopro_dir=$(ls -d linux-amd64_deb* 2>/dev/null | head -n 1)
    if [ -z "$cryptopro_dir" ] || [ ! -d "$cryptopro_dir" ]; then
        echo -e "${RED}Не удалось найти распакованную директорию с deb-пакетами.${NC}"
        return 1
    fi

    # Переход в директорию с deb-пакетами
    cd "$cryptopro_dir" || {
        echo -e "${RED}Ошибка при переходе в директорию $cryptopro_dir.${NC}"
        return 1
    }

    # Установка всех deb-пакетов
    echo -e "${BLUE}Установка deb-пакетов КриптоПро CSP...${NC}"
    sudo dpkg -i *.deb
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Обнаружены неудовлетворенные зависимости. Исправляем...${NC}"
        sudo apt-get update
        sudo apt-get install -f -y
        if [ $? -ne 0 ]; then
            echo -e "${RED}Ошибка при установке КриптоПро CSP или исправлении зависимостей.${NC}"
            cd .. || return 1
            return 1
        fi
    fi

    # Возврат в исходную директорию
    cd .. || {
        echo -e "${RED}Ошибка при возврате в исходную директорию.${NC}"
        return 1
    }

    echo -e "${GREEN}КриптоПро CSP успешно установлен.${NC}"

    # Проверка версии КриптоПро
    cryptopro_version=$(/opt/cprocsp/bin/amd64/cryptcp --version 2>/dev/null | grep -oP '\d+\.\d+')
    if [[ "$cryptopro_version" =~ ^5\.[0-9]+$ ]]; then
        echo -e "${RED}Установлена версия $cryptopro_version с поддержкой КС2 (ГОСТ Р 34.10-2012), что не соответствует требованию 'только КС1'.${NC}"
        echo -e -n "${YELLOW}Удалить установленную версию и прервать установку? (y/n): ${NC}"
        read remove_choice
        if [[ "$remove_choice" =~ ^[Yy]$ ]]; then
            sudo apt purge -y cprocsp-*
            echo -e "${YELLOW}КриптоПро CSP удален. Скачайте версию 4.0 (без КС2) с сайта cryptopro.ru и повторите установку.${NC}"
            return 1
        else
            echo -e "${YELLOW}Установка версии $cryptopro_version продолжена, несмотря на поддержку КС2.${NC}"
        fi
    elif [[ "$cryptopro_version" =~ ^4\.[0-9]+$ ]]; then
        echo -e "${GREEN}Установлена версия $cryptopro_version без поддержки КС2 (только ГОСТ Р 34.10-2001), как требуется.${NC}"
    else
        echo -e "${YELLOW}Не удалось определить версию КриптоПро. Проверьте установку вручную: /opt/cprocsp/bin/amd64/cryptcp --version${NC}"
    fi

    # Запрос ввода лицензионного ключа
    echo -e -n "${YELLOW}Введите лицензионный ключ для КриптоПро CSP (например, 50503-P0000-0197W-TA2AB-DWG2R): ${NC}"
    read license_key
    if [ -z "$license_key" ]; then
        echo -e "${RED}Лицензионный ключ не введен. Установка завершена без активации лицензии.${NC}"
    else
        echo -e "${BLUE}Ввод лицензионного ключа для КриптоПро CSP...${NC}"
        sudo /opt/cprocsp/sbin/amd64/cpconfig -license -set "$license_key"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Лицензионный ключ $license_key успешно установлен.${NC}"
        else
            echo -e "${RED}Ошибка при вводе лицензионного ключа. Проверьте его корректность или повторите вручную командой: sudo /opt/cprocsp/sbin/amd64/cpconfig -license -set <ключ>${NC}"
        fi
    fi

    # Запрос перезагрузки
    echo -e -n "${YELLOW}Требуется перезагрузка для завершения установки КриптоПро CSP. Перезагрузить сейчас? (y/n): ${NC}"
    read reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo -e "${YELLOW}Перезагрузка отложена. Пожалуйста, перезагрузите систему вручную для завершения установки.${NC}"
    fi
}

# Функция для выполнения всех пунктов
run_all() {
    update_sources_list
    update_system
    install_packages
    configure_network
    create_user
    setup_shared_directory
    setup_windows_credentials
    setup_network_mount
    install_cryptopro
}

# Основной цикл скрипта
while true; do
    show_menu
    echo -e -n "${YELLOW}Введите номер пункта: ${NC}"
    read choice
    case $choice in
        1) update_sources_list && update_system ;;
        2) install_packages ;;
        3) configure_network ;;
        4) create_user ;;
        5) setup_shared_directory ;;
        6) setup_windows_credentials ;;
        7) setup_network_mount ;;
        8) install_cryptopro ;;
        9) run_all ;;
        10) break ;;
        *) echo -e "${RED}Неверный выбор. Попробуйте снова.${NC}" ;;
    esac
    echo -e -n "${BLUE}Нажмите Enter чтобы продолжить...${NC}"
    read
done

echo -e "${GREEN}Скрипт завершен.${NC}"

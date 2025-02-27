#!/bin/bash

# Определение цветов
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color (сброс цвета)

# Функция для очистки экрана
clear_screen() {
    clear
}

# Анимация шагающего человечка
walking_man_animation() {
    clear_screen
    echo -e "${YELLOW}Добро пожаловать! Вот шагающий человечек:${NC}"
    sleep 1

    # Кадр 1: Стоит прямо
    clear_screen
    echo -e "${GREEN}"
    echo "    O  "
    echo "   /|\\ "
    echo "   / \\ "
    echo -e "${NC}"
    sleep 0.4

    # Кадр 2: Шаг правой ногой
    clear_screen
    echo -e "${GREEN}"
    echo "    O  "
    echo "   /|\\ "
    echo "   /|  "
    echo "  /    "
    echo -e "${NC}"
    sleep 0.4

    # Кадр 3: Стоит прямо
    clear_screen
    echo -e "${GREEN}"
    echo "    O  "
    echo "   /|\\ "
    echo "   / \\ "
    echo -e "${NC}"
    sleep 0.4

    # Кадр 4: Шаг левой ногой
    clear_screen
    echo -e "${GREEN}"
    echo "    O  "
    echo "   /|\\ "
    echo "    |\\ "
    echo "     \\ "
    echo -e "${NC}"
    sleep 0.4

    clear_screen
    echo -e "${YELLOW}Анимация завершена. Переходим к меню...${NC}"
    sleep 1
}

# Функция для отображения меню
show_menu() {
    echo -e "${BLUE}Выберите пункт меню:${NC}"
    echo -e "1. ${YELLOW}Обновить /etc/apt/sources.list и обновить систему${NC}"
    echo -e "2. ${YELLOW}Установить необходимые пакеты${NC}"
    echo -e "3. ${YELLOW}Настроить сеть${NC}"
    echo -e "4. ${YELLOW}Создать нового пользователя${NC}"
    echo -e "5. ${YELLOW}Создать каталог /media/shared/common и настроить права${NC}"
    echo -e "6. ${YELLOW}Создать файл .windowscredentials для монтирования сетевого каталога${NC}"
    echo -e "7. ${YELLOW}Настроить монтирование сетевой папки в /etc/fstab${NC}"
    echo -e "8. ${YELLOW}Установить КриптоПро CSP \(только КС1, без КС2\)${NC}"
    echo -e "9. ${YELLOW}Установить Wine${NC}"
    echo -e "10. ${YELLOW}Установить Bitrix24 Desktop${NC}"
    echo -e "11. ${YELLOW}Установить дополнительные программы \(Yandex Browser, Fly-DM RDP, Remmina\)${NC}"
    echo -e "12. ${YELLOW}Настроить X11VNC для удаленного доступа${NC}"
    echo -e "13. ${YELLOW}Выполнить все пункты${NC}"
    echo -e "14. ${YELLOW}Выйти${NC}"
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

    if command -v cprocsp-uninstall.sh &>/dev/null; then
        echo -e "${YELLOW}КриптоПро CSP уже установлен на системе.${NC}"
        return 0
    fi

    echo -e "${BLUE}Установка необходимых пакетов для КриптоПро CSP...${NC}"
    sudo apt update
    sudo apt install -y whiptail libccid pcscd libpcsclite1 opensc libengine-pkcs11-openssl*
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке необходимых пакетов для КриптоПро. Проверьте интернет или репозитории.${NC}"
        return 1
    fi
    echo -e "${GREEN}Необходимые пакеты для КриптоПро успешно установлены.${NC}"

    cryptopro_archive="linux-amd64_deb.tgz"
    if [ ! -f "$cryptopro_archive" ]; then
        echo -e "${RED}Архив $cryptopro_archive не найден в текущей директории.${NC}"
        echo -e "${YELLOW}Пожалуйста, скачайте дистрибутив КриптоПро CSP версии 4.0 (только КС1, без КС2) с сайта cryptopro.ru (раздел 'Центр загрузки') и поместите его в текущую директорию как 'linux-amd64_deb.tgz'.${NC}"
        return 1
    fi

    echo -e "${BLUE}Распаковка архива $cryptopro_archive...${NC}"
    sudo tar -xzf "$cryptopro_archive"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при распаковке архива КриптоПро.${NC}"
        return 1
    fi

    cryptopro_dir=$(ls -d linux-amd64_deb* 2>/dev/null | head -n 1)
    if [ -z "$cryptopro_dir" ] || [ ! -d "$cryptopro_dir" ]; then
        echo -e "${RED}Не удалось найти распакованную директорию с deb-пакетами.${NC}"
        return 1
    fi

    cd "$cryptopro_dir" || {
        echo -e "${RED}Ошибка при переходе в директорию $cryptopro_dir.${NC}"
        return 1
    }

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

    cd .. || {
        echo -e "${RED}Ошибка при возврате в исходную директорию.${NC}"
        return 1
    }

    echo -e "${GREEN}КриптоПро CSP успешно установлен.${NC}"

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

    echo -e -n "${YELLOW}Требуется перезагрузка для завершения установки КриптоПро CSP. Перезагрузить сейчас? (y/n): ${NC}"
    read reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo -e "${YELLOW}Перезагрузка отложена. Пожалуйста, перезагрузите систему вручную для завершения установки.${NC}"
    fi
}

# Функция для установки Wine
install_wine() {
    echo -e "${BLUE}Установка Wine и связанных пакетов...${NC}"
    sudo apt update
    echo -e "${BLUE}Установка пакетов Wine, winetricks, zenity, playonlinux...${NC}"
    sudo apt install -y wine winetricks zenity playonlinux
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке Wine или связанных пакетов. Проверьте интернет или репозитории.${NC}"
        return 1
    fi

    echo -e "${BLUE}Обновление winetricks...${NC}"
    sudo winetricks --self-update -q
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Winetricks успешно обновлен.${NC}"
    else
        echo -e "${YELLOW}Ошибка при обновлении winetricks, но установка Wine завершена.${NC}"
    fi

    echo -e "${BLUE}Установка wine-gecko и wine-mono...${NC}"
    sudo apt install -y wine-mono wine-gecko
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Wine-gecko и wine-mono успешно установлены.${NC}"
    else
        echo -e "${YELLOW}Ошибка при установке wine-gecko/wine-mono, но они могут быть уже включены в Wine.${NC}"
    fi

    echo -e "${GREEN}Установка Wine и связанных пакетов завершена (только 64-битная версия).${NC}"
    echo -e -n "${YELLOW}Рекомендуется перезагрузка после установки Wine. Перезагрузить сейчас? (y/n): ${NC}"
    read reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo -e "${YELLOW}Перезагрузка отложена. Wine готов к использованию.${NC}"
    fi
}

# Функция для установки Bitrix24 Desktop
install_bitrix24() {
    echo -e "${BLUE}Установка Bitrix24 Desktop...${NC}"
    if dpkg -l | grep -q bitrix24-desktop; then
        echo -e "${YELLOW}Bitrix24 Desktop уже установлен на системе.${NC}"
        return 0
    fi

    bitrix_url="https://repos.1c-bitrix.ru/b24/bitrix24_desktop_ru.deb"
    bitrix_deb="bitrix24_desktop_ru.deb"
    echo -e "${BLUE}Скачивание $bitrix_deb...${NC}"
    sudo wget -O "$bitrix_deb" "$bitrix_url"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при скачивании Bitrix24 Desktop. Проверьте интернет или URL: $bitrix_url${NC}"
        return 1
    fi

    echo -e "${BLUE}Установка Bitrix24 Desktop...${NC}"
    sudo dpkg -i "$bitrix_deb"
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Обнаружены неудовлетворенные зависимости. Исправляем...${NC}"
        sudo apt-get update
        sudo apt-get install -f -y
        if [ $? -ne 0 ]; then
            echo -e "${RED}Ошибка при установке Bitrix24 Desktop или исправлении зависимостей.${NC}"
            sudo rm -f "$bitrix_deb"
            return 1
        fi
    fi

    sudo rm -f "$bitrix_deb"
    echo -e "${GREEN}Bitrix24 Desktop успешно установлен.${NC}"
    echo -e -n "${YELLOW}Рекомендуется перезагрузка после установки Bitrix24 Desktop. Перезагрузить сейчас? (y/n): ${NC}"
    read reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo -e "${YELLOW}Перезагрузка отложена. Bitrix24 Desktop готов к использованию.${NC}"
    fi
}

# Функция для установки дополнительных программ (Yandex Browser, Fly-DM RDP, Remmina)
install_additional_apps() {
    echo -e "${BLUE}Установка дополнительных программ (Yandex Browser, Fly-DM RDP, Remmina)...${NC}"
    sudo apt update
    echo -e "${BLUE}Установка yandex-browser-stable, fly-dm-rdp, remmina...${NC}"
    sudo apt install -y yandex-browser-stable fly-dm-rdp remmina
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке дополнительных программ. Проверьте интернет или репозитории.${NC}"
        return 1
    fi
    echo -e "${GREEN}Дополнительные программы успешно установлены.${NC}"

    echo -e "${BLUE}Настройка CUPS для отображения только обнаруженных принтеров...${NC}"
    cups_conf="/etc/cups/client.conf"
    if [ ! -f "$cups_conf" ]; then
        sudo touch "$cups_conf"
    fi
    if ! grep -q "DiscoveredOnly Yes" "$cups_conf"; then
        echo "DiscoveredOnly Yes" | sudo tee -a "$cups_conf" > /dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Настройка CUPS обновлена: отображаются только обнаруженные принтеры.${NC}"
        else
            echo -e "${RED}Ошибка при обновлении $cups_conf.${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Настройка CUPS уже содержит DiscoveredOnly Yes.${NC}"
    fi

    echo -e "${BLUE}Перезапуск службы CUPS...${NC}"
    sudo systemctl restart cups
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Служба CUPS успешно перезапущена.${NC}"
    else
        echo -e "${RED}Ошибка при перезапуске службы CUPS.${NC}"
        return 1
    fi

    echo -e -n "${YELLOW}Рекомендуется перезагрузка после установки программ и настройки CUPS. Перезагрузить сейчас? (y/n): ${NC}"
    read reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo -e "${YELLOW}Перезагрузка отложена. Программы готовы к использованию.${NC}"
    fi
}

# Функция для настройки X11VNC
install_x11vnc() {
    echo -e "${BLUE}Настройка X11VNC для удаленного доступа...${NC}"

    # Обновление списка пакетов
    sudo apt update

    # Установка x11vnc
    echo -e "${BLUE}Установка x11vnc...${NC}"
    sudo apt install -y x11vnc
    if [ $? -ne 0 ]; then
        echo -e "${RED}Ошибка при установке x11vnc. Проверьте интернет или репозитории.${NC}"
        return 1
    fi
    echo -e "${GREEN}x11vnc успешно установлен.${NC}"

    # Создание файла службы
    service_file="/etc/systemd/system/x11vnc.service"
    echo -e "${BLUE}Создание файла службы $service_file...${NC}"
    sudo bash -c "cat > $service_file <<EOF
[Unit]
Description=Start x11vnc at startup.
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbport 5900 -shared -dontdisconnect -rfbauth /etc/x11vnc.pass -o /var/log/x11vnc.log

[Install]
WantedBy=multi-user.target
EOF"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Файл службы $service_file успешно создан.${NC}"
    else
        echo -e "${RED}Ошибка при создании файла службы $service_file.${NC}"
        return 1
    fi

    # Создание пароля для VNC через временный файл
    echo -e "${BLUE}Создание пароля для X11VNC...${NC}"
    temp_pass_file=$(mktemp)  # Создаём временный файл
    echo "vnc13" > "$temp_pass_file"  # Записываем пароль в файл
    sudo x11vnc -storepasswd "$temp_pass_file" /etc/x11vnc.pass  # Передаём файл в команду
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Пароль для X11VNC успешно установлен (vnc13).${NC}"
    else
        echo -e "${RED}Ошибка при создании пароля для X11VNC.${NC}"
        rm -f "$temp_pass_file"  # Удаляем временный файл в случае ошибки
        return 1
    fi
    rm -f "$temp_pass_file"  # Удаляем временный файл после успеха

    # Перезапуск служб и активация x11vnc
    echo -e "${BLUE}Перезапуск служб и активация X11VNC...${NC}"
    sudo systemctl daemon-reload
    sudo systemctl enable x11vnc.service
    sudo systemctl start x11vnc.service
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}X11VNC успешно настроен и запущен (порт 5900, пароль: vnc13).${NC}"
    else
        echo -e "${RED}Ошибка при настройке или запуске X11VNC.${NC}"
        return 1
    fi

    # Запрос перезагрузки
    echo -e -n "${YELLOW}Требуется перезагрузка для завершения настройки X11VNC. Перезагрузить сейчас? (y/n): ${NC}"
    read reboot_choice
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo -e "${YELLOW}Перезагрузка отложена. X11VNC уже работает.${NC}"
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
    install_wine
    install_bitrix24
    install_additional_apps
    install_x11vnc
}

# Запуск анимации перед началом скрипта
walking_man_animation

# Основной цикл скрипта
while true; do
    clear_screen
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
        9) install_wine ;;
        10) install_bitrix24 ;;
        11) install_additional_apps ;;
        12) install_x11vnc ;;
        13) run_all ;;
        14) break ;;
        *) echo -e "${RED}Неверный выбор. Попробуйте снова.${NC}" ;;
    esac
    echo -e -n "${BLUE}Нажмите Enter чтобы продолжить...${NC}"
    read
done

echo -e "${GREEN}Скрипт завершен.${NC}"

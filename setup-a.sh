#!/bin/bash

# Функция для вывода меню
show_menu() {
    echo "Выберите пункт меню:"
    echo "1. Обновить /etc/apt/sources.list и обновить систему"
    echo "2. Установить необходимые пакеты"
    echo "3. Настроить сеть"
    echo "4. Создать нового пользователя"
    echo "5. Выполнить все пункты"
    echo "6. Выйти"
}

# Функция для обновления /etc/apt/sources.list
update_sources_list() {
    echo "Обновление /etc/apt/sources.list..."
    sudo bash -c 'cat > /etc/apt/sources.list <<EOF
# Основной репозиторий, включающий актуальное оперативное или срочное обновление
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/main-repository/     1.8_x86-64 main contrib non-free non-free-firmware
# Расширенный репозиторий, соответствующий актуальному оперативному обновлению
deb https://dl.astralinux.ru/astra/stable/1.8_x86-64/extended-repository/ 1.8_x86-64 main contrib non-free non-free-firmware
EOF'
    echo "Файл /etc/apt/sources.list обновлен."
}

# Функция для обновления системы с использованием dist-upgrade
update_system() {
    echo "Обновление системы (включая обновление дистрибутива)..."
    sudo apt-get update && sudo apt-get dist-upgrade -y
    echo "Обновление системы завершено."
}

# Функция для установки необходимых пакетов
install_packages() {
    echo "Установка пакетов..."
    sudo apt-get install -y curl git vim
    echo "Установка пакетов завершена."
}

# Функция для настройки сети
configure_network() {
    echo "Настройка сети..."
    # Пример настройки сети
    sudo echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    echo "Настройка сети завершена."
}

# Функция для создания нового пользователя
create_user() {
    echo "Создание нового пользователя..."
    read -p "Введите имя нового пользователя: " username
    sudo adduser $username
    echo "Пользователь $username создан."
}

# Функция для выполнения всех пунктов
run_all() {
    update_sources_list
    update_system
    install_packages
    configure_network
    create_user
}

# Основной цикл скрипта
while true; do
    show_menu
    read -p "Введите номер пункта: " choice
    case $choice in
        1) update_sources_list && update_system ;;
        2) install_packages ;;
        3) configure_network ;;
        4) create_user ;;
        5) run_all ;;
        6) break ;;
        *) echo "Неверный выбор. Попробуйте снова." ;;
    esac
    read -p "Нажмите Enter чтобы продолжить..."
done

echo "Скрипт завершен."

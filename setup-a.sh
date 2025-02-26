#!/bin/bash

# Функции для различных задач настройки
update_system() {
    echo "Обновление системы..."
    sudo apt update && sudo apt upgrade -y
}

install_packages() {
    echo "Установка необходимых пакетов..."
    sudo apt install -y curl wget vim git
}

setup_firewall() {
    echo "Настройка брандмауэра..."
    sudo ufw enable
    sudo ufw allow OpenSSH
}

create_user() {
    read -p "Введите имя нового пользователя: " username
    sudo adduser "$username"
    sudo usermod -aG sudo "$username"
    echo "Пользователь $username добавлен и включен в группу sudo."
}

# Функция отображения меню
show_menu() {
    update_system
    echo "Выберите действие:"
    echo "1) Установить пакеты"
    echo "2) Настроить брандмауэр"
    echo "3) Создать пользователя"
    echo "4) Выполнить всё"
    echo "0) Выход"
    read -p "Введите номер пункта меню: " choice
    case $choice in
        1) install_packages ;;
        2) setup_firewall ;;
        3) create_user ;;
        4) install_packages; setup_firewall; create_user ;;
        0) exit 0 ;;
        *) echo "Неверный выбор!" ;;
    esac
}

# Основной цикл
while true; do
    show_menu
    read -p "Нажмите Enter для продолжения..." temp
done

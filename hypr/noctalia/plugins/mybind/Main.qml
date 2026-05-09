// ~/.config/noctalia/plugins/veter-keyboard-controls/Main.qml
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    // Регистрация IPC-обработчика для нашего плагина
    IpcHandler {
        target: "plugin:mybind"

        //Вывести help
        function helloWorld() {
            // Вывод в консоль — наш индикатор успеха
            console.log("Hello World! Plugin command received!");
        }

        // Открыть панель управления звуком
        function openAudioPanel() {
            Quickshell.ipc("audioPanel", "open");
        }

        // Открыть панель уведомлений
        function openNotificationPanel() {
            Quickshell.ipc("notifications", "open");
        }

        // Открыть центр управления (Wi-Fi, Bluetooth, настройки)
        function openControlPanel() {
            Quickshell.ipc("controlCenter", "open");
        }
    }
}

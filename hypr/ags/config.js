// Импортируем необходимые модули из astal
import { App } from 'astal/gtk3';
import { Widget } from 'astal/gtk3/widget';

// Функция для создания бара на конкретном мониторе
function Bar(monitor) {
    // Возвращаем окно, которое будет прикреплено к верху экрана
    return Widget.Window({
        name: `bar-${monitor.model}`, // уникальное имя для каждого монитора
        monitor: monitor.model,        // номер монитора (0, 1, ...)
        anchor: 'top',                 // привязка к верху экрана
        exclusivity: 'exclusive',      // занимает место, не перекрывается другими окнами
        child: Widget.CenterBox({      // виджет с тремя зонами: лево, центр, право
            start_widget: Widget.Label({ label: 'left' }),
            center_widget: Widget.Label({ label: 'center' }),
            end_widget: Widget.Label({ label: 'right' }),
        }),
    });
}

// Запускаем приложение
App.start({
    css: `${App.configDir}/style.css`, // путь к файлу стилей
    main() {
        // Создаём бар на каждом подключённом мониторе
        App.get_monitors().map(Bar);
    },
});

// test-legacy-gi.js
const { App, Gtk, Widget } = imports.gi;

// Указываем нужную версию Astal (4 соответствует libastal-4)
imports.gi.versions.Astal = '3';
const Astal = imports.gi.Astal;

function MyTestWidget() {
    return Astal.Widget.Window({
        name: "test-window",
        anchor: Astal.Gtk.CornerType.TOP | Astal.Gtk.CornerType.LEFT | Astal.Gtk.CornerType.RIGHT,
        exclusivity: "exclusive",
        child: Astal.Widget.Label({
            label: "Hello from AGS!",
        }),
    });
}

Astal.App.start({
    main() {
        MyTestWidget();
    },
});

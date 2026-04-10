// test-astal.js
const { Gtk } = imports.gi;

// Указываем версию Astal (4 — последняя)
imports.gi.versions.Astal = '3';
const Astal = imports.gi.Astal;

function MyTestWidget() {
    return Astal.Widget.Window({
        name: "test-window",
        anchor: Gtk.CornerType.TOP | Gtk.CornerType.LEFT | Gtk.CornerType.RIGHT,
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

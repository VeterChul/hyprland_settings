// test.js
import { App, Gtk, Widget } from 'astal';

function MyTestWidget() {
  return Widget.Window({
    name: "test-window",
    anchor: Gtk.CornerType.TOP | Gtk.CornerType.LEFT | Gtk.CornerType.RIGHT,
    exclusivity: "exclusive",
    child: Widget.Label({
      label: "Hello from AGS!",
    }),
  });
}

App.start({
  main() {
    MyTestWidget();
  },
});

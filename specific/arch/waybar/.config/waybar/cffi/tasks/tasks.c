// cffi/tasks: waybar taskbar with minimize support (Hyprland).
// Data and window actions come from tasks.sh; this file only draws buttons and routes clicks.
//   left click   -> focus (restore if minimized)
//   middle click -> close
//   right click  -> context menu
// Config keys: "monitor" (required), "script" (default ~/.config/waybar/cffi/tasks/tasks.sh), "size" (default 20)
#include <json-glib/json-glib.h>
#include <signal.h>

#include "waybar_cffi_module.h"

const size_t wbcffi_version = 2;

typedef struct {
  GtkBox* box;
  char* script;
  char* monitor;
  int size;
  GCancellable* cancel;
  // Everything but titles; rebuilding buttons under the cursor makes hover flicker, so only rebuild when this changes
  char* layout;
  guint timer;        // coalesces signal bursts (terminal titles change many times a second)
  gboolean running;   // a list call is in flight
  gboolean again;     // a signal arrived while it was
} Tasks;

typedef struct {
  const char* label;
  const char* action;
} MenuEntry;

static void run_action(Tasks* t, const char* action, const char* address) {
  const char* argv[] = {t->script, action, address, NULL};
  g_spawn_async(NULL, (char**)argv, NULL, G_SPAWN_SEARCH_PATH, NULL, NULL, NULL, NULL);
}

static void on_menu_item(GtkMenuItem* item, Tasks* t) {
  run_action(t, g_object_get_data(G_OBJECT(item), "action"), g_object_get_data(G_OBJECT(item), "address"));
}

static void add_menu_item(GtkMenuShell* menu, Tasks* t, const char* label, const char* action,
                          const char* address) {
  if (!label) {
    gtk_menu_shell_append(menu, gtk_separator_menu_item_new());
    return;
  }
  GtkWidget* item = gtk_menu_item_new_with_label(label);
  g_object_set_data(G_OBJECT(item), "action", (gpointer)action);
  g_object_set_data_full(G_OBJECT(item), "address", g_strdup(address), g_free);
  g_signal_connect(item, "activate", G_CALLBACK(on_menu_item), t);
  gtk_menu_shell_append(menu, item);
}

static gboolean destroy_menu(gpointer menu) {
  gtk_widget_destroy(menu);
  return G_SOURCE_REMOVE;
}

static void on_menu_closed(GtkMenuShell* menu) { g_idle_add(destroy_menu, menu); }

static void show_menu(Tasks* t, GtkWidget* button, GdkEvent* event) {
  const char* address = g_object_get_data(G_OBJECT(button), "address");
  gboolean minimized = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "minimized"));
  gboolean floating = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "floating"));
  gboolean pinned = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "pinned"));
  gboolean fullscreen = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "fullscreen"));

  GtkMenuShell* menu = GTK_MENU_SHELL(gtk_menu_new());
  add_menu_item(menu, t, minimized ? "Restore" : "Minimize", minimized ? "restore" : "minimize", address);
  add_menu_item(menu, t, floating ? "Tile" : "Untile (float)", "float", address);
  add_menu_item(menu, t, fullscreen ? "Exit fullscreen" : "Fullscreen", "fullscreen", address);
  // Hyprland only pins floating windows
  if (floating) add_menu_item(menu, t, pinned ? "Unpin" : "Pin", "pin", address);
  add_menu_item(menu, t, NULL, NULL, NULL);
  add_menu_item(menu, t, "Close", "close", address);
  // Kill signals the window's process, which takes every window of that process with it
  int siblings = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "siblings"));
  char* kill_label = g_strdup_printf("Kill app (SIGTERM, closes %d window%s)", siblings, siblings == 1 ? "" : "s");
  char* force_label = g_strdup_printf("Force kill app (SIGKILL, closes %d window%s)", siblings, siblings == 1 ? "" : "s");
  add_menu_item(menu, t, kill_label, "kill", address);
  add_menu_item(menu, t, force_label, "forcekill", address);
  g_free(kill_label);
  g_free(force_label);

  gtk_widget_show_all(GTK_WIDGET(menu));
  // GTK emits deactivate before the chosen item's activate, so free the menu on the next idle
  g_signal_connect(menu, "deactivate", G_CALLBACK(on_menu_closed), NULL);
  gtk_menu_popup_at_pointer(GTK_MENU(menu), event);
}

static gboolean on_press(GtkWidget* button, GdkEventButton* event, Tasks* t) {
  if (event->type != GDK_BUTTON_PRESS) return TRUE;
  const char* address = g_object_get_data(G_OBJECT(button), "address");
  gboolean minimized = GPOINTER_TO_INT(g_object_get_data(G_OBJECT(button), "minimized"));
  switch (event->button) {
    case 1:
      run_action(t, minimized ? "restore" : "focus", address);
      break;
    case 2:
      run_action(t, "close", address);
      break;
    case 3:
      show_menu(t, button, (GdkEvent*)event);
      break;
  }
  return TRUE;
}

// GTK3 ignores gtk-tooltip-timeout, so gate the tooltip: refuse queries until the pointer
// has rested TOOLTIP_DELAY_MS on the button, then ask GTK to show it
#define TOOLTIP_DELAY_MS 200

static gboolean on_tooltip_timer(gpointer button) {
  g_object_set_data(G_OBJECT(button), "tooltip-timer", NULL);
  g_object_set_data(G_OBJECT(button), "tooltip-ready", GINT_TO_POINTER(TRUE));
  gtk_widget_trigger_tooltip_query(button);
  return G_SOURCE_REMOVE;
}

static void stop_tooltip_timer(GtkWidget* button) {
  guint timer = GPOINTER_TO_UINT(g_object_get_data(G_OBJECT(button), "tooltip-timer"));
  if (timer) g_source_remove(timer);
  g_object_set_data(G_OBJECT(button), "tooltip-timer", NULL);
}

static gboolean on_enter(GtkWidget* button, GdkEvent* event, gpointer data) {
  (void)event, (void)data;
  stop_tooltip_timer(button);
  g_object_set_data(G_OBJECT(button), "tooltip-timer",
                    GUINT_TO_POINTER(g_timeout_add(TOOLTIP_DELAY_MS, on_tooltip_timer, button)));
  return FALSE;
}

static gboolean on_leave(GtkWidget* button, GdkEvent* event, gpointer data) {
  (void)event, (void)data;
  stop_tooltip_timer(button);
  g_object_set_data(G_OBJECT(button), "tooltip-ready", NULL);
  return FALSE;
}

static gboolean on_query_tooltip(GtkWidget* button, gint x, gint y, gboolean keyboard, GtkTooltip* tooltip,
                                 gpointer data) {
  (void)x, (void)y, (void)keyboard, (void)data;
  if (!g_object_get_data(G_OBJECT(button), "tooltip-ready")) return FALSE;
  gtk_tooltip_set_text(tooltip, g_object_get_data(G_OBJECT(button), "title"));
  return TRUE;
}

static GtkWidget* make_button(Tasks* t, JsonObject* win) {
  GtkWidget* button = gtk_button_new();
  GtkStyleContext* style = gtk_widget_get_style_context(button);
  const char* address = json_object_get_string_member(win, "address");

  g_object_set_data_full(G_OBJECT(button), "address", g_strdup(address), g_free);
  const char* flags[] = {"minimized", "active", "floating", "pinned", "fullscreen"};
  for (size_t i = 0; i < G_N_ELEMENTS(flags); i++) {
    gboolean on = json_object_get_boolean_member(win, flags[i]);
    g_object_set_data(G_OBJECT(button), flags[i], GINT_TO_POINTER(on));
    if (on) gtk_style_context_add_class(style, flags[i]);
  }
  g_object_set_data(G_OBJECT(button), "siblings", GINT_TO_POINTER(json_object_get_int_member(win, "siblings")));

  GdkPixbuf* pixbuf =
      gdk_pixbuf_new_from_file_at_size(json_object_get_string_member(win, "icon"), t->size, t->size, NULL);
  GtkWidget* image = pixbuf ? gtk_image_new_from_pixbuf(pixbuf)
                            : gtk_image_new_from_icon_name("application-x-executable", GTK_ICON_SIZE_BUTTON);
  if (pixbuf) g_object_unref(pixbuf);
  if (json_object_get_boolean_member(win, "pinned")) {
    // Small thumbtack (FontAwesome U+F08D) in the icon's top-right corner, styled as #tasks .pin-badge
    GtkWidget* overlay = gtk_overlay_new();
    GtkWidget* badge = gtk_label_new("");
    gtk_widget_set_halign(badge, GTK_ALIGN_END);
    gtk_widget_set_valign(badge, GTK_ALIGN_START);
    gtk_style_context_add_class(gtk_widget_get_style_context(badge), "pin-badge");
    gtk_container_add(GTK_CONTAINER(overlay), image);
    gtk_overlay_add_overlay(GTK_OVERLAY(overlay), badge);
    image = overlay;
  }
  gtk_container_add(GTK_CONTAINER(button), image);
  g_object_set_data_full(G_OBJECT(button), "title", g_strdup(json_object_get_string_member(win, "title")), g_free);
  gtk_widget_set_has_tooltip(button, TRUE);
  g_signal_connect(button, "query-tooltip", G_CALLBACK(on_query_tooltip), NULL);
  g_signal_connect(button, "enter-notify-event", G_CALLBACK(on_enter), NULL);
  g_signal_connect(button, "leave-notify-event", G_CALLBACK(on_leave), NULL);
  g_signal_connect(button, "destroy", G_CALLBACK(stop_tooltip_timer), NULL);
  g_signal_connect(button, "button-press-event", G_CALLBACK(on_press), t);
  return button;
}

static char* layout_of(JsonArray* windows) {
  GString* s = g_string_new(NULL);
  for (guint i = 0; i < json_array_get_length(windows); i++) {
    JsonObject* w = json_array_get_object_element(windows, i);
    g_string_append_printf(s, "%s|%s|%d%d%d%d%d|%ld;", json_object_get_string_member(w, "address"),
                           json_object_get_string_member(w, "icon"), json_object_get_boolean_member(w, "minimized"),
                           json_object_get_boolean_member(w, "active"), json_object_get_boolean_member(w, "floating"),
                           json_object_get_boolean_member(w, "pinned"),
                           json_object_get_boolean_member(w, "fullscreen"),
                           (long)json_object_get_int_member(w, "siblings"));
  }
  return g_string_free(s, FALSE);
}

static void render(Tasks* t, JsonArray* windows) {
  char* layout = layout_of(windows);
  GList* children = gtk_container_get_children(GTK_CONTAINER(t->box));

  if (g_strcmp0(layout, t->layout) == 0) {
    // Same buttons, only titles may differ
    guint i = 0;
    for (GList* l = children; l; l = l->next, i++)
      g_object_set_data_full(
          G_OBJECT(l->data), "title",
          g_strdup(json_object_get_string_member(json_array_get_object_element(windows, i), "title")), g_free);
    g_list_free(children);
    g_free(layout);
    return;
  }

  for (GList* l = children; l; l = l->next) gtk_widget_destroy(l->data);
  g_list_free(children);
  for (guint i = 0; i < json_array_get_length(windows); i++)
    gtk_container_add(GTK_CONTAINER(t->box), make_button(t, json_array_get_object_element(windows, i)));
  gtk_widget_show_all(GTK_WIDGET(t->box));
  gtk_widget_set_visible(GTK_WIDGET(t->box), json_array_get_length(windows) > 0);
  g_free(t->layout);
  t->layout = layout;
}

static void reload(Tasks* t);

static void on_list(GObject* source, GAsyncResult* res, gpointer data) {
  char* out = NULL;
  // Cancelled by deinit: the instance is gone, don't touch it
  if (!g_subprocess_communicate_utf8_finish(G_SUBPROCESS(source), res, &out, NULL, NULL)) return;
  Tasks* t = data;

  JsonParser* parser = json_parser_new();
  if (out && json_parser_load_from_data(parser, out, -1, NULL))
    render(t, json_node_get_array(json_parser_get_root(parser)));
  g_object_unref(parser);
  g_free(out);

  t->running = FALSE;
  if (t->again) {
    t->again = FALSE;
    reload(t);
  }
}

static void reload(Tasks* t) {
  if (t->running) {
    t->again = TRUE;
    return;
  }
  GSubprocess* proc = g_subprocess_new(G_SUBPROCESS_FLAGS_STDOUT_PIPE, NULL, t->script, "list", t->monitor, NULL);
  if (!proc) return;
  t->running = TRUE;
  g_subprocess_communicate_utf8_async(proc, NULL, t->cancel, on_list, t);
  g_object_unref(proc);
}

static gboolean on_timer(gpointer data) {
  Tasks* t = data;
  t->timer = 0;
  reload(t);
  return G_SOURCE_REMOVE;
}

// Config values arrive JSON-encoded ("\"DP-1\"", "20")
static char* config_string(const char* json) {
  JsonNode* node = json_from_string(json, NULL);
  char* value = node && JSON_NODE_HOLDS_VALUE(node) ? g_strdup(json_node_get_string(node)) : NULL;
  if (node) json_node_unref(node);
  return value;
}

void* wbcffi_init(const wbcffi_init_info* info, const wbcffi_config_entry* config, size_t config_len) {
  Tasks* t = g_new0(Tasks, 1);
  t->size = 20;
  for (size_t i = 0; i < config_len; i++) {
    if (g_str_equal(config[i].key, "monitor")) t->monitor = config_string(config[i].value);
    if (g_str_equal(config[i].key, "script")) t->script = config_string(config[i].value);
    if (g_str_equal(config[i].key, "size")) t->size = atoi(config[i].value);
  }
  if (!t->monitor) {
    g_printerr("cffi/tasks: \"monitor\" is required\n");
    g_free(t);
    return NULL;
  }
  if (!t->script) t->script = g_build_filename(g_get_home_dir(), ".config/waybar/cffi/tasks/tasks.sh", NULL);
  if (t->script[0] == '~') {
    char* expanded = g_build_filename(g_get_home_dir(), t->script + 1, NULL);
    g_free(t->script);
    t->script = expanded;
  }

  t->cancel = g_cancellable_new();
  t->box = GTK_BOX(gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0));
  gtk_widget_set_name(GTK_WIDGET(t->box), "tasks");
  gtk_container_add(GTK_CONTAINER(info->get_root_widget(info->obj)), GTK_WIDGET(t->box));
  reload(t);
  return t;
}

void wbcffi_deinit(void* instance) {
  Tasks* t = instance;
  if (t->timer) g_source_remove(t->timer);
  g_cancellable_cancel(t->cancel);
  g_object_unref(t->cancel);
  g_free(t->script);
  g_free(t->monitor);
  g_free(t->layout);
  g_free(t);
}

// tasks.sh and the Hyprland event hooks send SIGRTMIN+8 after every change
void wbcffi_refresh(void* instance, int signal) {
  Tasks* t = instance;
  if (signal != SIGRTMIN + 8 || t->timer) return;
  t->timer = g_timeout_add(100, on_timer, t);
}

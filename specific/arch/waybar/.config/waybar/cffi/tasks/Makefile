tasks.so: tasks.c waybar_cffi_module.h
	$(CC) -shared -fPIC -O2 -Wall -Wextra -o $@ tasks.c $$(pkg-config --cflags --libs gtk+-3.0 json-glib-1.0)

clean:
	rm -f tasks.so

.PHONY: clean

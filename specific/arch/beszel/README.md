# Beszel agent (neumann-arch)

Sends metrics to the hub at `https://beszel.homelab.lsantos.me` (multivac, reached
over Tailscale).

Installed from the AUR as `beszel-agent-bin`, which ships the systemd unit, creates
the `beszel` system user, and reads `/etc/beszel-agent.conf`.

## Secrets are not in this repo

**This repo is public.** The agent's `TOKEN` is a credential, so the real config
lives only at `/etc/beszel-agent.conf`, root-owned and `0600`. Only the sanitized
example and the systemd drop-in are tracked here.

## Setting it up on a new machine

```bash
yay -S beszel-agent-bin smartmontools rocm-smi-lib

# Real config, with KEY and TOKEN from the hub's "Add System" dialog
sudo cp specific/arch/beszel/etc/beszel-agent.conf.example /etc/beszel-agent.conf
sudo chmod 600 /etc/beszel-agent.conf
sudo $EDITOR /etc/beszel-agent.conf   # fill in KEY and TOKEN

# Drop-in, symlinked back to this repo
sudo mkdir -p /etc/systemd/system/beszel-agent.service.d
sudo ln -sfn "$PWD/specific/arch/beszel/etc/systemd/system/beszel-agent.service.d/10-local.conf" \
  /etc/systemd/system/beszel-agent.service.d/10-local.conf

sudo systemctl daemon-reload
sudo systemctl enable --now beszel-agent
```

## Why the drop-in exists

The packaged unit runs as the `beszel` user with `CAP_SYS_RAWIO` for `smartctl`,
but no supplementary groups. Docker's socket is `root:docker 0660`, so container
metrics need the `docker` group. `video` and `render` are insurance for
`rocm-smi`; on this box `/dev/dri/renderD128` is already world-accessible.

## Sensor names are not what `sensors` prints

Keys are gopsutil-style: the hwmon chip name plus the label, lowercased and joined
with `_`. So `Tctl` is `k10temp_tctl`, not `Tctl`. A wrong name in `SENSORS`
silently reports no temperatures rather than erroring.

To read the real list:

```bash
sudo sed -i '$a LOG_LEVEL=debug' /etc/beszel-agent.conf
sudo systemctl restart beszel-agent
journalctl -u beszel-agent -n 50 | grep Temperatures
sudo sed -i '/^LOG_LEVEL=debug$/d' /etc/beszel-agent.conf
sudo systemctl restart beszel-agent
```

The whitelist in the example config exists because this board reports several
junk channels. `nct6798_auxtin3` sits at a meaningless 79 °C and was being picked
as the dashboard temperature, `asusec_t_sensor` reads -40 °C with no thermistor
fitted, and the `nct6798_pch_*` channels all report 0.

## Verifying

```bash
systemctl status beszel-agent
journalctl -u beszel-agent -n 20        # expect "WebSocket connected"
beszel-agent health
```

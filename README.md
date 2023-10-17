[grit](https://en.wikipedia.org/wiki/Grit_(personality_trait)) is a simple dart program that transforms qBittorrent torrents/info API calls into NZBGet status and listgroups responses.

grit allows clients like LunaSea (https://www.lunasea.app/) to display qBittorrent downloads using NZBGet integration.

For now, only the display of the realtime queue is supported (list of queued files with current status and download speed).

## Installation

- Host the server somewhere (Docker image available at ghcr.io/open-tooling/grit:latest)
- Add your server to LunaSea using the NZBGet integration (use your qBittorrent credentials as NZBGet credentials)
- In the Custom Headers section, create:
  - grit-host = your qBittorrent host
  - grit-port = your qBittorrent port
  - grit-protocol = http or https

If you don't want to use the credentials through the application for some reason, you can force them with environment variables using `grit-credentials`. Value should be like: `username:password`.
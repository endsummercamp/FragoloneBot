# PlanetBot
Bot Telegram per l'esportazione in chat degli eventi prossimi sul [Calendario LUG](https://planet.linux.it/lug/eventi.php) fornito da [Italian Linux Society](http://www.ils.org/).

La configurazione e il codice sono riutilizzabili per mostrare gli eventi prossimi di qualunque calendario iCalendar (Google Calendar, esportazione NextCloud, _etc._).

## Prerequisiti
`apt install ruby ruby-dev bundler` (o equivalente nella vostra distro)

## Installazione
- Ottenere un token API da [BotFather](https://t.me/BotFather)
- Modificare il file `config.yml.example` inserendo il token ricevuto e rinominarlo in `config.yml`
- Eseguire `bundle install`
- Avviare il bot con `./manage_planetbot.rb start` (sono supportati anche stop, restart, status)
 

---
title: "we have `it.genova.amt.app` at home"
date: 2026-06-25
---

recently I have been playing with the android application for my city's public transportation system, the following is a recap:

the `it.genova.amt.app` app fires 3 requests to populate `/data/data/it.genova.amt.app/databases/AMT.db`: 

+ [app_lines.php](https://www.amt.genova.it/amt/servizi/app/dati/app_lines.php)
+ [app_stops.php](https://www.amt.genova.it/amt/servizi/app/dati/app_stops.php)
+ [app_lines_stops.php](https://www.amt.genova.it/amt/servizi/app/dati/app_lines_stops.php)

these endpoints return a semicolumn-separated file we can use to populate a local sqlite db (check [`updater.py`](https://g.rcastellotti.dev/rc/tma/src/branch/main/updater.py)), then, live info (timetables and departures) can be retrieved using the following endpoints:

+ [orari_xml.php?linea=001&gg=19&mm=6&aa=2026](https://www.amt.genova.it/amt/servizi/orari_xml.php?linea=001&gg=19&mm=6&aa=2026)
+ [passaggi_xml.php?CodiceFermata=0360](https://www.amt.genova.it/amt/servizi/passaggi_xml.php?CodiceFermata=0360)

this makes spinning up an alternative service quite trivial: you can use mine at [tma.rcastellotti.dev](https://tma.rcastellotti.dev) and check source code at [https://g.rcastellotti.dev/rc/tma](https://g.rcastellotti.dev/rc/tma), please report bugs and rememeber to validate your ticket before hopping on a bus :)

## resources

+ https://emanuele-f.github.io/PCAPdroid/quick_start
+ https://emanuele-f.github.io/PCAPdroid/tls_decryption
+ https://docs.mitmproxy.org/stable/concepts/certificates
+ https://play.google.com/store/apps/details?id=it.genova.amt.app

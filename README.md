# deep_shield
FiveM ESX Shield Item Resource by deep

This resource is an edited version of the original shield resource by xander!

About the script - HU

A scriptről

Teljeskörűen Konfigolható

Itemmel működik - sql mellékelt (esx 1.2 vagy nagyobb verzióhoz át kell írni a limit-et weight-re) 
Az item neve(amivel beaddolod) configba állítható, az in game látható neve sql-be (label)

Ad ammo-t ha be van kapcsolva configba. Konfigurálható, hogy mennyi ammotól adjon és mennyit.
Ad ammo-t ha egy bizonyos mennyiség alatt van nálad, ez a mennyiség és az adott ammo mennyisége
állítható configba, ez a funkció kikapcsolható.

Konfigurálható, hogy milyen fegyverekkel lehet használni (Pisztoly ajánlott, esetleg bugolhat is nagyobb fegyverrel)
Az értesítések konfigurálhatóak .

Mikor használod a shield-et a kezedben kell lennie egy fegyvernek, ha nincs a script automatikusan a legutóbbi fegyvered veszi elő,
vagy ha nincs legutóbbi értesít, hogy végy elő pisztolyt.

Optimalizált
- nem használatban - 0.1 ms
- használatban - min 0.2 max 0.5 - átlag 0.3

Ha shield használata közben elteszed a fegyvered, elveszi tőled a shield-et.
Ha shield használata közben elesel, elveszi tőled a shield-et.
Ha shield használata közben meghalsz, elveszi tőled a shield-et.
Ha shield használata közben vízbe mész, elveszi tőled a shield-et.
Ha shield használata közben q-t nyomsz, azaz fedezékbe mész, elveszi tőled a shield-et.
Nem ülhetsz be autóba shield használata közben, mivel autóval használva bugos, ha megpróbálod elveszi tőled a shield-et.

A shield elrakásának leggyorsabb módja a más fegyverre váltás (akár kéz).

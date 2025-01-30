# Observabilité

<div style="display:flex; column-gap: 10%;">
  <img src="./ressources/Grafana_logo.png" alt="grafana" width="80"/>
  <img src="./ressources/Timescale_Logo.png" alt="grafana" width="400"/>
  <img src="./ressources/Prometheus_software_logo.png" alt="grafana" width="80"/>
</div>

## Table des matières

- [Introduction](#introduction)
- [Prérecquis](#prérecquis)
- [Déploiement des containers Postgres_Exporter Prometheus Grafana](#déploiement-des-containers-postgres_exporter-prometheus-grafana)
- [Dump de la base de données Databox](#dump-de-la-base-de-données-databox)
- [Podman commands tips](#podman-commands-tips)
  - [Créer un réseau externe](#créer-un-réseau-externe)
  - [Connecter un container à un réseau externe](#connecter-un-container-à-un-réseau-externe)
  - [Inspecter un réseau externe](#inspecter-un-réseau-externe)
  - [Tester la communication entre deux containers](#tester-la-communication-entre-deux-containers)
- [Configuration de Grafana](#configuration-de-grafana)
  - [Les sources de données](#les-sources-de-données)
  - [Les dashboards](#les-dashboards)
  - [Les plugins](#les-plugins)
  - [Les alertes](#les-alertes)
- [Configuration de Prometheus](#configuration-de-prometheus)
- [Configuration de Postgres_Exporter](#configuration-de-postgres_exporter)
- [Pour poursuivre](#pour-poursuivre)

## Introduction

L'objectif est de produire une stack permettant l'observabilité d'une base de données TimescaleDb afin de pouvoir étudier le comportement de la base de données lors de load testing.

La stack utilisée est la suivante :

- TimescaleDb : Base de données Time series basée sur PostgreSQL
- Postgres_Exporter : Exporter de metriques pour Prometheus
- Prometheus : Outil de monitoring et générateur d'alerte
- Grafana : Outil de visualisation et supervision de metriques

L'utilisation de Podman a été privilégié afin de permettre un déploiement rapide et flexible des différents outils.

[Back to top](#observabilité)

## Prérecquis

- Podman
- Podman Desktop
- Définir vos login/password dans le fichier **compose.yaml**

  - Grafana :
    - Login : admin
    - Password : grafana
  - TimescaleDb :
    - Nom de la base de données : databox
    - User : postgres
    - Password : mypassword
  - Postgres_exporter : - User : monitoring - Password: monitoring

    > [!CAUTION]
    > Concernant Postgres_exporter login/password sont à modifier dans **compose.yaml** et dans **./timescaledb/init.sql**

[Back to top](#observabilité)

## Déploiement des containers Postgres_Exporter Prometheus Grafana

Exécuter la commande ci-dessous afin de créer l'arborescence recquise

```bash
setup.bat
```

Se placer à la racine du projet et exécuter la commande suivante :

```bash
podman compose up
```

- [Tester que l'export de metriques est fonctionnel](http://127.0.0.1:9187/metrics)

- [Ouvrir Prometheus](http://127.0.0.1:9090)

- [Ouvrir Grafana](http://127.0.0.1:3000)

[Back to top](#observabilité)

## Dump de la base de données Databox

Commandes psql de dump et restore sur un serveur local

```bash
pg_dump -h host_source -U user_source -Fc db_source > backup_file.dump

pg_restore -h host_destination -U user_destination -d db_destination backup_file.dump
```

Il est également possible de générer le dump depuis DBeaver :

- Clique droit sur la base de données à dump
- Sélectionner Outils > Backup ou Global Backup
- Choissisez les base de données, les schémas, les tables et tout ce que vous souhaiter sauvegarder
- Sélectionner les options de sauvegarde dont le format
- Démarrer la sauvegarde

```bash
# Get container id
podman container ps -q -f name=timescaledb

# Create folder for dump file
podman exec timescaledb mkdir -p /home/postgres/sql

## Inside folder of input file, Copy file to container on windows 11
## Caution name of machine Podman !
wsl -d podman-machine-default -u root enterns podman cp fichierentrant.sql timescaledb:/home/postgres/sql/script.sql
# or
wsl -d podman-machine-default -u root enterns podman cp fichierentrant.dump timescaledb:/home/postgres/sql/db.dump

## Connect to container
podman exec -it timescaledb bash

## Execute script
psql -d databox < /home/postgres/sql/script.sql
# or
psql -d databox < /home/postgres/sql/db.dump
```

[Back to top](#observabilité)

## Podman commands tips

### Créer un réseau externe

Un réseau externe permet de faire communiquer plusieurs containers dans des groupes différents

```bash
podman network create monitoring_network
```

### Connecter un container à un réseau externe

Une fois le réseau externe créer il faut ajouter les containers au réseau

```bash
docker network connect monitoring_network containerName
```

### Inspecter un réseau externe

```bash
podman network inspect monitoring_network
```

### Tester la communication entre deux containers

Suivant la configuration les droits root peuvent être recquis, malgré tout cette commande permet de valider la bonne communication entre containers

```bash
podman exec prometheus ping postgres_exporter
```

[Back to top](#observabilité)

## Configuration de Grafana

[Repo dev grafana](https://github.com/grafana/grafana/tree/main/devenv)

### Les sources de données

Les sources de données se configurent dans le fichier :

> ./grafana/datasources/datasource.yml

> [!NOTE]
> Pour aller plus loin, voir la [documentation](https://grafana.com/docs/grafana/latest/datasources/)

### Les dashboards

[Lien vers les templates proposés par Grafana](https://grafana.com/grafana/dashboards/)

En suivant le lien ci-dessus vous pouvez choisir des templates par recherche. Les templates sont des fichiers JSON q'il faut placer dans le répertoire :

> ./grafana/dashboards

> [!NOTE]
> Pour aller plus loin, voir la [documentation](https://grafana.com/docs/grafana/latest/dashboards/)

### Les plugins

> [!NOTE]
> Pour aller plus loin, voir la [documentation](https://grafana.com/docs/grafana/latest/dashboards/)

### Les alertes

> [!WARNING]
> Les alertes peuvent également être gérées dans Prometheus

> [!NOTE]
> Pour aller plus loin, voir la [documentation](https://grafana.com/docs/grafana/latest/alerting/)

[Back to top](#observabilité)

## Configuration de Prometheus

Create prometheus/prometheus.yml  
Create grafana/datasource.yml  
Create compose.yaml

[Exemple repo github](https://github.com/docker/awesome-compose/blob/master/prometheus-grafana/README.md)

> [Open Prometheus](http://127.0.0.1:9090)

[Back to top](#observabilité)

## Configuration de Postgres_Exporter

[Lien de documentation TimescaleDb](https://docs.timescale.com/use-timescale/latest/metrics-logging/metrics-to-prometheus)  
[Lien de documentation Github](https://github.com/prometheus-community/postgres_exporter)

Créer un rôle spécifique sur la base de données monitorées pour l'accès de Postgres Exporter

```sql
CREATE USER monitoring WITH PASSWORD 'monitoring';

GRANT pg_read_all_stats to monitoring;

GRANT EXECUTE ON FUNCTION pg_ls_waldir TO monitoring;
```

[Back to top](#observabilité)

## Pour poursuivre

- Fix Buffers graph du PostgreSQL Exporter Quickstart and Dashboard dans Grafana
- Intégrer les dahboard qui ne sont pas intégrer
- [Repo for improve Grafana config](https://github.com/grafana/xk6-output-timescaledb/tree/main)

[Back to top](#observabilité)

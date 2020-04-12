#!/usr/bin/env bash
#
# Script to test various application reverse proxies, as well as their internal pages, and report to their respective Healthchecks.io checks
# Tronyx

# Define some variables
# Primary domain all of your reverse proxies are hosted on
domain='domain.com'

# Your Organizr API key to get through Org auth
orgAPIKey=''

# Primary Server IP address of the Server all of your applications/containers are hosted on
# You can add/utilize more Server variables if you would like, as I did below, and if you're running more than one Server like I am
primaryServerAddress='192.168.1.103'
hcPingDomain='https://hc-ping.com/'

# Location of the lock file that you can utilize to keep tests paused.
tempDir='/tmp/'
# The below temp dir is for use with the Tronitor script, uncomment the line if you wish to use it
# https://github.com/christronyxyocum/tronitor
#tempDir='/tmp/tronitor/'
healthchecksLockFile="${tempDir}healthchecks.lock"

# You will need to adjust the subDomain, appPort, subDir, and hcUUID variables for each application's function according to your setup
# I've left in some examples to show the expected format.

# Function to check for healthchecks lock file
check_lock_file() {
  if [ -e "${healthchecksLockFile}" ]; then
    echo "Skipping checks due to lock file being present."
    exit 0
  else
    main
  fi
}

# Function to check Organizr public Domain
check_organizr() {
  appPort='8889'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Bitwarden
check_bitwarden() {
  subDomain='bitwarden'
  appPort='8484'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}")
  intResponse=$(curl -k -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Deluge
check_deluge() {
  appPort='8112'
  subDir='/deluge/'
  hcUUID=''
  extResponse=$(curl -o /dev/null --connect-timeout 10 -s -w "%{http_code}\n" https://"${domain}":"${appPort}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -o /dev/null --connect-timeout 10 -s -w "%{http_code}\n" http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check GitLab
check_gitlab() {
  subDomain='gitlab'
  appPort='444'
  subDir='/users/sign_in'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -k -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Grafana
check_grafana() {
  subDomain='grafana'
  appPort='3000'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Guacamole
check_guacamole() {
  appPort='8080'
  subDir='/guac/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Jackett
check_jackett() {
  appPort='9117'
  subDir='/jackett/UI/Login'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 https://"${domain}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}" -s -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check PLPP
check_library() {
  subDomain='library'
  appPort='8383'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Lidarr
check_lidarr() {
  appPort='8686'
  subDir='/lidarr/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Logarr
check_logarr() {
  appPort='8000'
  subDir='/logarr/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check TheLounge
check_thelounge() {
  appPort='9090'
  subDir='/thelounge/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}" -sI -o /dev/null --connect-timeout 10 https://"${domain}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Monitorr
check_monitorr() {
  appPort='8001'
  subDir='/monitorr/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Nagios
check_nagios() {
  subDomain='nagios'
  appPort='8787'
  subDir=''
  nagUser=''
  nagPass=''
  hcUUID=''
  extResponse=$(curl -u "${nagUser}:${nagPass}" -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -u "${nagUser}:${nagPass}" -k -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Nextcloud
check_nextcloud() {
    subDomain='nextcloud'
    appPort='9393'
    hcUUID=''
    extResponse=$(curl -w "%{http_code}\n" -sIL -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}" -H "token: ${orgAPIKey}")
    intResponse=$(curl -k -w "%{http_code}\n" -sIL -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
    appName=$(echo ${FUNCNAME[0]} |cut -c7-)
    appLockFile="${tempDir}${appName}".lock
    if [ -e "${appLockFile}" ]; then
      :
    else
      if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
        curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
      elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
        curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
      fi
    fi
}

# Function to check NZBGet
check_nzbget() {
  appPort='6789'
  subDir='/nzbget/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check NZBHydra/NZBHydra2
check_nzbhydra() {
  appPort='5076'
  subDir='/nzbhydra/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Ombi
check_ombi() {
  appPort='3579'
  subDir='/ombi/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check PiHole
check_pihole() {
  subDomain='pihole'
  subDir='/admin/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Plex
check_plex() {
  subDir='/plex/'
  appPort='32400'
  hcUUID=''
  plexExtResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${domain}""${subDir}")
  plexIntResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}"/web/index.html)
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${plexExtResponse}" = '200' ]] && [[ "${plexIntResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${plexExtResponse}" != '200' ]] || [[ "${plexIntResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Portainer
check_portainer() {
  appPort='9000'
  subDir='/portainer/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Radarr
check_radarr() {
  appPort='7878'
  subDir='/radarr/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check ruTorrent
check_rutorrent() {
  subDomain='rutorrent'
  appPort='9080'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 https://"${subDomain}"."${domain}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -s -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '401' ]] && [[ "${intResponse}" = '401' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '401' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check SABnzbd
check_sabnzbd() {
  appPort='8580'
  subDir='/sabnzbd/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Sonarr
check_sonarr() {
  appPort='9898'
  subDir='/sonarr/'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Tautulli
check_tautulli() {
  appPort='8181'
  subDir='/tautulli/auth/login'
  hcUUID=''
  extResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 https://"${domain}${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -w "%{http_code}\n" -sI -o /dev/null --connect-timeout 10 http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Function to check Transmission
check_transmission() {
  appPort='9091'
  subDir='/transmission/web/index.html'
  hcUUID=''
  extResponse=$(curl -o /dev/null --connect-timeout 10 -s -w "%{http_code}\n" https://"${domain}":"${appPort}""${subDir}" -H "token: ${orgAPIKey}")
  intResponse=$(curl -o /dev/null --connect-timeout 10 -s -w "%{http_code}\n" http://"${primaryServerAddress}":"${appPort}""${subDir}")
  appName=$(echo ${FUNCNAME[0]} |cut -c7-)
  appLockFile="${tempDir}${appName}".lock
  if [ -e "${appLockFile}" ]; then
    :
  else
    if [[ "${extResponse}" = '200' ]] && [[ "${intResponse}" = '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}" > /dev/null
    elif [[ "${extResponse}" != '200' ]] || [[ "${intResponse}" != '200' ]]; then
      curl -fsS --retry 3 "${hcPingDomain}${hcUUID}"/fail > /dev/null
    fi
  fi
}

# Main function to run all other functions
# Uncomment (remove the # at the beginning of the line) to enable the checks you want
main() {
    check_organizr
    #check_bitwarden
    #check_deluge
    #check_gitlab
    #check_grafana
    #check_guacamole
    #check_jackett
    #check_library
    #check_lidarr
    #check_logarr
    #check_thelounge
    #check_monitorr
    #check_nagios
    #check_nextcloud
    #check_nzbget
    #check_nzbhydra
    #check_ombi
    #check_pihole
    #check_plex
    #check_portainer
    #check_radarr
    #check_rutorrent
    #check_sabnzbd
    #check_sonarr
    #check_tautulli
    #check_transmission    
}

check_lock_file

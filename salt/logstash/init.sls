# Copyright 2014,2015,2016,2017,2018 Security Onion Solutions, LLC

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Logstash Section

logstashgroup:
  group.present:
    - name: logstash
    - gid: 931

# Add the logstash user for the jog4j settings
logstash:
  user.present:
    - uid: 931
    - gid: 931
    - home: /opt/so/conf/logstash

lsconfdir:
  file.directory:
    - name: /opt/so/conf/logstash/conf.d
    - user: 931
    - group: 939
    - makedirs: True

# Copy down all the configs
lssync:
  file.recurse:
    - name: /opt/so/conf/logstash
    - source: salt://logstash/files
    - user: 931
    - group: 939

# Create the import directory
importdir:
  file.directory:
    - name: /nsm/import
    - user: 931
    - group: 939
    - makedirs: True

# Create the logstash data directory
nsmlsdir:
  file.directory:
    - name: /nsm/logstash
    - user: 931
    - group: 939
    - makedirs: True

# Create the log directory
lslogdir:
  file.directory:
    - name: /opt/so/log/logstash
    - user: 931
    - group: 939
    - makedirs: True


# Add the container

so-logstash:
  dockerng.running:
    - image: pillaritem/so-logstash
    - hostname: logstash
    - user: logstash
    - environment:
      - LS_JAVA_OPTS=-Xms{{ lsheap }} -Xmx{{ lsheap }}
    - port_bindings:
      - 5044
      - 6050
      - 6051
      - 6052
      - 6053
      - 9600
    - binds:
      - /opt/so/conf/logstash/log4j2.properties:/usr/share/logstash/config/log4j2.properties:ro
      - /opt/so/conf/logstash/logstash.yml:/usr/share/logstash/config/logstash.yml:ro
      - /opt/so/conf/logstash/logstash-template.json:/logstash-template.json:ro
      - /opt/so/conf/logstash/beats-template.json:/beats-template.json:ro
      - /opt/so/conf/logstash/conf.d:/usr/share/logstash/pipeline/:ro
      - /opt/so/rules:/etc/nsm/rules:ro
      - /opt/so/conf/logstash/dictionaries:/lib/dictionaries:ro
      - /nsm/import:/nsm/import:ro
      - /nsm/logstash:/usr/share/logstash/data:rw
      - /opt/so/log/logstash:/var/log/logstash:rw
    - network_mode: so-elastic-net

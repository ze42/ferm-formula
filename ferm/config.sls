{% set templates = {
   'ferm.conf': 'ferm.conf.jinja',
   'conf.d/10-policies.conf': 'policies.conf.jinja',
   'conf.d/20-conn-helpers.conf': 'conn-helpers.conf.jinja',
   'conf.d/50-rules.conf': 'rules.conf.jinja',
}
%}


include:
  - .service

{% for filename, templatename in templates|dictsort %}
ferm_{{filename}}:
  file.managed:
    - name: /etc/ferm/{{ filename }}
    - source: salt://{{ slspath }}/templates/{{ templatename }}
    - template: jinja
    - makedirs: True
    - onchanges_in:
      - file: ferm_baseconfig
{% endfor %}

# Touch, so reload notice there has been changes...
# Debian init script uses cache, and only launch ferm to parse configuration if
# ferm.conf was changed since last generation.
ferm_baseconfig:
  file.touch:
    - name: /etc/ferm/ferm.conf
    - watch_in:
      - service: ferm_service
